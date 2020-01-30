# HomeFries

A simple attempt at implementing the [Geohash](https://en.wikipedia.org/wiki/Geohash) algorithm in Elixir.

## Features
- Encode locations (given as latitude, longitude) in string or tuple format with `HomeFries.encode/2`
- Decode hashes to a string containing the latitude and longitude with `HomeFries.decode/1`
