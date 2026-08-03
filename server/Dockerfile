# ---Basic setup---

# Using debian penultimate stable version, bookworm (12). Trixie(13) is the latest!
FROM debian:bookworm

# Let's update all the packages
RUN apt update -y && apt upgrade -y

# Let's just install the best text editor in the world and curl
RUN apt install vim -y && apt install curl -y