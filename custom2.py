import os

START_FOLDER = "./src"  # Change this to your desired start folder
SEARCH_TERMS = ["secrets", "api_key", "password"]
FILE_EXTENSIONS = [".py", ".js"]  # Add or remove extensions as needed


def search_files(start_folder, search_terms, file_extensions):
    for root, _, files in os.walk(start_folder):
        for file in files:
            if any(file.endswith(ext) for ext in file_extensions):
                file_path = os.path.join(root, file)
                with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                    for i, line in enumerate(f, 1):
                        for term in search_terms:
                            if term in line:
                                print(f"{file_path}:{i}: {line.strip()}")


if __name__ == "__main__":
    search_files(START_FOLDER, SEARCH_TERMS, FILE_EXTENSIONS)
