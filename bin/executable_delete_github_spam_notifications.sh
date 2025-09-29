#! /usr/bin/env bash

# get all active notifications, take note of the id's
gh api notifications | jq '.[] | { id, title: .subject.title, repo: .repository.full_name }'

# {
#   "id": "19169556111",
#   "title": "Paradigm Announcement | $80M GitHub & Paradigm PD25 [Closed pre-registration]",
#   "repo": "capital-paradigm/paradigm"
# }
# {
#   "id": "19144307033",
#   "title": "Y-Combinator W2026 | $15M Y-Combinator & GitHub",
#   "repo": "ycombbinator/-co"
# }

# Now delete the individual notifications with those id's
# gh api --method DELETE notifications/threads/19169556111
while read -p "Enter the notification id: " id; do
	if [[ -z "${id}" ]]; then
		exit 0
	else
		echo "Deleting id: ${id}"
		# gh api --method DELETE notifications/threads/${id}
	fi
done
