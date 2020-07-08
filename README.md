# Auction Edge

These example problems are similar to what we run into where we get car data
from a wide variety of sources, and need to normalize the data. Many times
users will have typos or use shorthand in a given field.

## Code Challenge

### Instructions:

Please complete the normalize_data function below to make the examples pass.
Feel free to add classes or helper methods as needed. Include the version of
ruby you ran your code in as a comment at the top of the file.

### Things to consider:

- "trim" refers to different features or packages for the same model of
  vehicle.
- Valid years are from 1900 until 2 years in the future from today
- A value that can't be normalized should be returned as is
- Sometimes the trim of a vehicle will be provided in the "model" field, and
  will need to be extracted to the "trim" field
- The word "blank" should be returned as nil

## Solution

When I started work on the challenge, I wrote something rather simple and ran the code as described in the original code sample. However, considering that this code is part of an ETL process, which is typically rather critical, I expanded on it include full test coverage.

Given more resources, I would store the constants at the beginning of the file in some sort of database. That way, definitions could easily be updated without requiring a code push. The definition structure is `regex => value` so it wouldn't need anything sophisticated. A Postgres with two columns should be plenty.

Something else I would add is logging. I'm sure that we want to know if a record contains invalid data. It could be as simple as a key on database record, or if that's not available or if more robust logging is needed, log it an external tool.

On the topic of database tables, if I created tables for  the data structures described, it would be shaped like:

automobiles:

- id: UUID PK NOT NULL
- make: VARCHAR(255) NOT NULL
- model: VARCHAR(255) NOT NULL
- year: INT (this is a problem because some years are strings)
- valid: BOOLEAN default FALSE

dictionaries:

- id: UUID PK NOT NULL
- reference_type: ENUM ('make', 'model', 'trim')
- lookup: VARCHAR(255) NOT NULL
- value: VARCHAR(255) NOT NULL

## Instructions

```bash
$ bundle install
$ ruby normalizer_test.rb

## Running:
#
# ...........
#
# Finished in 0.001922s, 5722.9072 runs/s, 10405.2857 assertions/s.
# 11 runs, 20 assertions, 0 failures, 0 errors, 0 skips
```


