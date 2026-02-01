from requests import get
import re


def fetch_mongodb_image():
    """Fetch MongoDB Docker image tags from Docker Hub."""
    url = "https://hub.docker.com/v2/repositories/mongodb/mongodb-enterprise-server/tags/?page_size=100"
    response = get(url, timeout=10)
    if response.status_code == 200:
        data = response.json()
        results = data.get("results", [])
        available_tags = sorted([
            item["name"]
            for item in results
            if re.match(r"^[0-9]+\.[0-9]+\.[0-9]+-ubuntu\d+$", item["name"])
            and item["tag_status"] == "active"
        ], reverse=True)
        for tag in available_tags:
            print(tag)
    else:
        print([])


fetch_mongodb_image()
