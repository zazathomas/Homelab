import subprocess

def run_command():
    try:
        backend = input("Enter the Target backend: ")
        pipeline = input("Enter the path to pipeline: ")
        rule = input("Enter the path to rule: ")
        output = input("Enter the output format(ruler/default): ")
        command = f"sigma convert -t {backend} -p {pipeline} {rule} -f {output}"
        # Run the command and capture the output
        output = subprocess.check_output(command, shell=True, universal_newlines=True)
        return output.strip()  # Return the output without leading/trailing whitespaces
    except subprocess.CalledProcessError as e:
        # Handle errors if the command fails
        print(f"Error: {e}")
        return None

# Example usage:
if __name__ == "__main__":
    # Command to run (replace with your desired command)
    command_to_run = "ls -l"
    
    # Run the command and save the output to a variable
    command_output = run_command()
    
    # Display the output
    if command_output is not None:
        command_output = command_output.replace("logfmt","json")
        command_output = command_output.replace("__","")
        print("Command Output:")
        print(command_output)
