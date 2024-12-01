import shutil
from typing import Any

class BasicLogger:
    """
    A basic logging class with color-coded output.

    This class provides methods for basic logging messages with color-coded output for better visibility.

    Example usage:
    logger = Logger()
    logger.log_info("This is an info message.")
    logger.log_error("This is an error message.")

    Attributes:
        RED (str): ANSI escape code for red text.
        GREEN (str): ANSI escape code for green text.
        YELLOW (str): ANSI escape code for yellow text.
        BLUE (str): ANSI escape code for blue text.
        WHITE (str): ANSI escape code for white text.
        RESET (str): ANSI escape code to reset text formatting.
        DIM (str): ANSI escape code for dim text.
    """

    # Define some basic colors
    RED = "\033[91m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    BLUE = "\033[94m"
    WHITE = "\033[97m"
    RESET = "\033[0m"
    DIM = "\033[2m"

    def get_terminal_width(self) -> int:
        """
        Get the width of the users terminal. Max width is 120 characters.
        """

        # Calculate the terminal window width
        terminal_size = shutil.get_terminal_size(
            fallback=(80, 20)  # Default to 80x20 if unable to get size
        )  
        width = terminal_size.columns

        # Max width is 120
        width = min(width, 120)

        return width

    def log(self, message: Any) -> None:
        """
        Log a normal message in white.

        Args:
            message: The message to be logged.
        """
        print(f"{self.WHITE} {message}{self.RESET}")

    def log_dim(self, message: Any) -> None:
        """
        Log an informational message in dim white.

        Args:
            message: The informational message to be logged.
        """
        print(f"{self.DIM}{self.WHITE} {message}{self.RESET}")

    def log_info(self, message: Any) -> None:
        """
        Log a dimmed message in yellow.

        Args:
            message: The message to be logged in dim yellow.
        """
        print(f"{self.DIM}{self.BLUE} {message}{self.RESET}")

    def log_error(self, message: Any) -> None:
        """
        Log an error message in dim red.

        Args:
            message: The error message to be logged.
        """
        print(f"{self.DIM}{self.RED} {message}{self.RESET}")

    def log_warning(self, message: Any) -> None:
        """
        Log a warning message in dim yellow.
        """
        print(f"{self.DIM}{self.YELLOW} {message}{self.RESET}")

    def log_separator(self) -> None:
        """
        Log a separator line.
        """

        # Get the terminal size
        width = self.get_terminal_width()

        # Print =- width/2 times
        print("=-" * (width // 2) + "=")

    def log_centered(self, message: Any) -> None:
        """
        Print a full-width message centered in the terminal.
        """

        # Get the terminal size
        width = self.get_terminal_width()

        # Adjust the message to fit the terminal width
        full_width_message = message.center(width, " ")

        # Print the message
        print(full_width_message)


#
# A simple test main method
#
if __name__ == "__main__":
    logger = BasicLogger()
    logger.log_separator()
    logger.log("This is a normal message.")
    logger.log_dim("This is a dim message.")
    logger.log_info("This is an info message.")
    logger.log_warning("This is a warning message.")
    logger.log_error("This is an error message.")
    logger.log_centered("This is a centered message")
    logger.log_separator()
