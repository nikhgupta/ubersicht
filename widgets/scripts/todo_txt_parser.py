#!/usr/bin/env python3


import re
import fileinput
from todotxt import Task


def get_task_text(task):
    text = str(task)
    text = re.sub(r"\(%s\)" % task.priority.name, "", text)
    for context in task.contexts:
        text = re.sub(r"@%s\b" % context, "", text)
    for project in task.projects:
        text = re.sub(r"\+%s\b" % project, "", text)
    return text.strip()


if __name__ == "__main__":
    tasks = [Task(line) for line in fileinput.input()]
    all = " ".join([task.html for task in Task.all_tasks().list])
    try:
        html = "<div class='column all'>%s</div> \
                <div class='column major'>%s</div>"
        working = Task.all_tasks().filter(context__in=('working')).list[0]
        working = get_task_text(working)
        print(html % (all, working))
    except IndexError:
        print(all)
