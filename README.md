# Gati

Folders here should contain following: 

1. rtl foldder 
2. tb folder 
3. project folder.

RTL has the RTL design files, tb has test bench files and project should have
the vivado .xpr file. Make sure that you dont upload the Waveform .wlf or .vcd
file. 

# Contribution Guidelines

## Using Branches for Organized Development

Branching allows you to develop a feature without disturbing the stable main
branch.

Branching starts with naming a branch. Branch names should be selected based on
the part of the problem you are working on. For example, if you are working on
im2col, simply create a branch called 'im2col. Or if you are working on a small
experimental part of a larger project, a branch name such as
'output_fifo_integration' would be suitable.

Pre-requisites for following this guide:
<https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell>

Before starting to work on a project, run

```
git pull origin main
```

This will fetch the latest main branch from the remote repo. 

New branch for a new project should be created from the current
latest branch.

Run,
```
git branch -c "<branch_name>"
```

All your work related to this specific project will happen on this branch. 

To check which branch you are currently in, run,
```
git branch
```

The branch name with a '\*' on its left is the current branch.

When adding and commiting make sure you do it on this branch.

After you've commited some changes, you may decide to push these changes to a
remote repository.

For this, run: 
```
git push origin <branch_name>
```

This pushes your changes to a remote copy of your branch. This is not the same
as pushing to main. After pushing to a remote copy of your branch, run
```
git branch -a
```

You should see two peculiar branches: `<branch_name>` and `origin/<branch_name>`.
The former is your local branch and the latter is the remote copy of your local
branch.

### Create a Pull Request

When the project is suitable to merge into the main branch, you'll have to
create a pull request. A pull request is a set of commits that are good enough 
to be merged into some other branch (usually the 'main' branch).

Do this by going to the github site for the project
(github.com/vicharak-in/Gati), and clicking on the "Pull Requests" tab. Click on
"Create new", select the branch from which the commits should be taken for a
pull request. Add a description for the pull request. On the right, select
one/many reviewers for your PR. Finally, click on "Submit".

### Reviewing/Being Reviewed

TODO

### More Organization via Nested Branches

TODO
