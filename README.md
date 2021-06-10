# oico-changelog

This project is the oico changelog gem.

**Features:**

- update CHANGELOG.md file
- create new release (add git tag)

## How to use

**To create a new entry:**

`Oico::Changelog::Entry.new(type: TYPE, ref_type: REF_TYPE, ref_id: REF_ID).write`

- TYPE: [:feature, :fix, :change]
- REF_TYPE: [:pull, :issue]
- REF_ID (pull request id or issue id)

**To merge all entries into CHANGELOG.md:**

`Oico::Changelog.new.merge!`

**To delete all entries:**

`Oico::Changelog.delete_entries!`

**To merge a new release into CHANGELOG.md:**

`Oico::Changelog.new.add_release!`

**To create a new release**

Major: `Oico::Changelog::Release.major`
Minor: `Oico::Changelog::Release.minor`
Patch: `Oico::Changelog::Release.patch`

## Configurations

environment variables:
  - REF_URL (github project url)

github credentials:
  - name: set your user name the same is in git (without whitespaces)
  - eg: git config --global credential.username "myusername"
