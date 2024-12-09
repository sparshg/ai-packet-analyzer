import re
import openai
import subprocess
import sys
import os
import tempfile
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()


MODEL = os.getenv("MODEL")

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


def get_python_code_from_openai(prompt):
    """Fetch Python code from OpenAI based on the input prompt."""
    try:
        response = client.chat.completions.create(
            model=MODEL,
            max_tokens=2048,
            temperature=0.2,
            messages=[
                {
                    "role": "system",
                    "content": [
                        {
                            "type": "text",
                            "text": 'You are a network expert, user gives you a query and has a "example.pcap" in same dir. You have access to tshark, python. Give the final answer of the user query as a single python program that the user can run to know the answer. You can only output python code as your answer. The user won\'t change your code.',
                        },
                    ],
                },
                {
                    "role": "user",
                    "content": [{"type": "text", "text": prompt}],
                },
            ],
        )
        code = response.choices[0].message.content
        match = re.search(r"```python\s+(.*?)\s+```", code, re.DOTALL)
        if match:
            return match.group(1).strip()
        return None

    except Exception as e:
        print(f"Error fetching code from OpenAI: {e}")
        sys.exit(1)


def run_code_isolated(code):
    """Run the generated Python code in an isolated environment."""
    try:
        with tempfile.NamedTemporaryFile(
            suffix=".py", mode="w", delete=False
        ) as temp_file:
            temp_file.write(code)
            temp_file_path = temp_file.name

        result = subprocess.run(
            [sys.executable, temp_file_path], capture_output=True, text=True
        )
        with open("temp.py", "w") as f:
            f.write(code)

        # os.remove(temp_file_path)
        print(temp_file_path)
        if result.returncode == 0:
            print("Output:\n", result.stdout)
        else:
            print("Error:\n", result.stderr)
    except Exception as e:
        print(f"Error executing code: {e}")


def main():
    if len(sys.argv) < 2:
        print("Usage: python cli_tool.py '<your prompt>'")
        sys.exit(1)

    # Join the prompt from command line arguments
    prompt = " ".join(sys.argv[1:])

    print(f"Generating Python program for: '{prompt}'")

    # Get Python code from OpenAI based on the prompt
    code = get_python_code_from_openai(prompt)

    # print(f"\nGenerated Python Code:\n{code}\n")

    # Execute the generated code and print the result
    run_code_isolated(code)


if __name__ == "__main__":
    main()
