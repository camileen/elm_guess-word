import json

if __name__ == "__main__":
    words = []
    with open("words.txt") as words_file:
        for line in words_file:
            words = line.split(' ')
    words_json = json.dumps({"words": words}, indent=5)

    with open("words.json", "w") as json_file:
        json_file.write(words_json)