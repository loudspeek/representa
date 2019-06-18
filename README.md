# Representa

Representa is a combination of a number of different source datasets about elected representatives for people in the UK. It is a fork based on the fantastic [EveryPolitician project](https://github.com/everypolitician/everypolitician-data) from MySociety, but aims only to cover the UK.

## Why does this fork exist?

MySociety unfortunately couldn't commit the resources to keeping EveryPolitician up to date forever, and as a consequence have chosen to put the project into a semi-archived state. Keeping the entirety of the world's political information up-to-date election upon election is a massive feat, and a special mention goes out to [Tony Bowden](https://github.com/tmtmtmtm), whose stellar work on EveryPolitician for many years created the amazing groundwork to make this dataset.

## Why just the UK?

The simple answer is resources. As mentioned above, it's incredibly difficult to maintain such a large number of countries' information, and as a matter of practicality, the current maintainer simply doesn't have the time to keep the project going with every country in the world. Unfortunately, this does inevitably lead to a smaller dataset.

---
The below information is from EveryPolitician's original README, and hasn't been modified. Its accuracy or usefulness can't be guaranteed.
---

## Want to use the data?

* [general information about how to _use_ the data](http://everypolitician.org/technical.html)
* if you want to download it, get it from:
  - human? go via the [EveryPolitician website](http://everypolitician.org)
  - program? use the RawGit CDN, via links in `countries.json`, which we [explain here](http://docs.everypolitician.org/repo_structure.html)
* [what's in the data?](http://docs.everypolitician.org/data_summary.html)

## Want to contribute data?

* [high-level information about how to contribute](http://everypolitician.org/contribute.html)

This repo is where we store the data, but we have a process for adding it — please don't
submit Pull Requests with data. Instead, if you know of data or data sources we are not
using, please get in touch: here's
[how to contribute](http://everypolitician.org/contribute.html). The bottom line is: we use
[multiple online sources](http://docs.everypolitician.org/sources.html), and we regularly
retrieve data from those sources so we can automatically keep up-to-date if and when they change.
If you can help us by providing more sources, great!

This document is for developers actively working _on_ the project, rather than consuming data from it.

## Building the data for a legislature

1. From within the directory for the legislature it should usually be enough to run `bundle exec rake clean default`.

    * To re-refetch the data from a given source first, set the REBUILD_SOURCE environment variable to something matching the filename of the required source: e.g. `REBUILD_SOURCE=official bundle exec rake clean default`

    * If you want to fetch fresh data from *all* existing sources, you can use `bundle exec rake clobber default` instead.

    * Note that if you're fetching any data from Morph, you'll also need to specify your [morph.io API key](https://morph.io/documentation/api) in the environment variable `MORPH_API_KEY`, e.g. `MORPH_API_KEY=my_secret_key bundle exec rake clean default`

2. Make sure that the changes look sensible, and then commit the new/refreshed data. Please commit human-edited files separately to data fetched from a remote source or generated as part of the build.
