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

### Working on a new project

Before starting to work on a project, run this while inside the main branch.

```
git pull origin main
```

This will fetch the latest main branch from the remote repo. 

New branch for a new project should be created from the current
latest branch (main).

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

The process of review is thus:

1. You create a PR and ask one/many of your peers for review of your code.
2. Your peers then review your code and comment if there are any extra changes
   to be made.
3. You follow through with the change.
4. When all the requested changes have been made, the admin will approve and
   merge your PR into main. This is the END of your PR.

### Making Changes after you've submitted a PR

While under review (after you've created a PR), you may be asked to implement
some changes. This is done in a similar way as you did add-commit-push before
creating a PR.

```
git commit --amend
```
will allow you to edit the **latest commit**. If a requested change is only
limited to the latest commit, this is all you need.

For changes, that require editing multiple commits, you need something that can
*change history*. **Rebase** is the tool for this job.

```
git rebase -i <commit_hash>^
```

Watch this [video](https://youtu.be/tukOm3Afd8s?si=IHJw0JJ8Veh4qvQB)to learn
more about it.

TODO: better decription of rebase

### Working on an existing project

Say you worked on a project, made some commits, pushed them to your branch,
created a PR and it got merged into main. There are two directions in which your
branch might go from here:

1. It will never be needed in the future, so it is deleted.
2. It is kept for future.

In the former case, it is almost as if the branch never existed in the first
place, life's good. In the latter case, if you want to work on the branch after
some time, chances are that this branch has become *stale*. 

You will have to rejuvenate this branch by fetching the latest main branch and
merging it into your current branch.

Checkout your branch,
```
git checkout <branch_name>
```
Fetch the main branch,
```
git fetch origin main
```
Merge the fetched branch into the current branch,
```
git merge FETCH_HEAD
```

Now, you may work on this branch.

### More Organization via Nested Branches

Think of branching as a family tree. The main branch is the eldest member of the
family (stable and not to be messed with). Branches created while you are in
main emerge from main i.e. they are the children of main. These are your project
related branches, for eg, 'im2col', 'systolic_array' etc. 

Your projects can be big/small. In the former case, it can be helpful to
organize your sub-branches (im2col etc.) into more sub branches. Think of them
as children of childrens.

Now, you have a main branch which is the global state of the project. Main
branch has sub-branches that have on-going projects. Sub-branches themselves
have sub-branches, so your sub-branch (im2col etc.) is the stable copy of your
project (and its sub-branches are the experimental branches).

This nested branching approach allows organized development and can lead to
better quality of code.

### Cheatsheet

```
git add
git commit
git commit --amend
git push <remote_name> <branch_name>
git pull
git fetch <remote_name> <branch_name>
git merge <branch_name>
git rebase -i <commit_hash>^

In rebase,
pick
drop
squash
re-ordering commits
```
