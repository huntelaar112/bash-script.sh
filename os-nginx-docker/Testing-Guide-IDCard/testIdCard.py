import argparse
import requests
import locale

def main():
    # Define command-line arguments
    parser = argparse.ArgumentParser(description="Image Recognition Script")
    parser.add_argument("--image", required=True, help="Path to the image file")
    parser.add_argument("--api-token-file", required=True, help="Path to the file containing the API token")
    args = parser.parse_args()

    # Read the API token from the file
    with open(args.api_token_file, "r") as token_file:
        api_key = token_file.read().strip()

    # Set the locale to Vietnamese
    locale.setlocale(locale.LC_ALL, 'vi_VN.UTF-8')

    url = 'http://localhost/idfull/v1/recognition'
    headers = {
        'api-key': api_key
    }

    files = {
        'image1': ('photo_2023-10-28_13-28-12.jpg', open(args.image, 'rb')),
        'image2': ('photo_2023-10-28_13-28-09.jpg', open(args.image, 'rb')),
    }

    data = {
        'encode': '1'
    }

    response = requests.post(url, headers=headers, files=files, data=data)
    print(response.json())

if __name__ == "__main__":
    main()
