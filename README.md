# Gati

> [!NOTE] 
> Gati docs and crash-course videos are hosted locally which you can
> access while in office premises. See #Gati slack channel for links.

# Contribution Guidelines

## General rules

1. Do *NOT* push code to the main branch
2. Read this document thoroughly before writing code.
3. Keep your lines under 80 columns (moreover, use an editor that automatically
   clips a line longer than 80 columns). This is mandatory in text files like
   README and documentation files.
4. Use tools that allow you to automate your workflow. (see under for some
   recommendations)


## Writing Programs (Style Guide)

### Coding Standard

Consistent style across a project makes reading/maintaining a codebase easier. 
We adopt [this Verilog style guidline for FPGA Design](/docs/verilog_style_guide.md).
You are advised to go through this througly before making any changes or adding new code.  

### Simulation

There are two recommendations for simulation softwares:

1. [verilator](https://verilator.org/)
2. [iverilog](https://steveicarus.github.io/iverilog/)

and for waveform viewers:

1. [gtkwave](https://gtkwave.sourceforge.net/)

All the above softwares can be installed in Ubuntu/Debian with:

```
sudo apt install iverilog verilator gtkwave
```

Refer to the guides present on the webpages of each program to learn more.

### Linting 

Further, it is recommended to use a
[lint](https://en.wikipedia.org/wiki/Lint_(software)) software to check programs
for common bugs that may occur. Verilator provides an option to lint programs:

```
verilator --top ${TOP_MODULE} --lint-only -Wall <source files>
```

### Formatting

Poor indentation/formatting is an eye sore. It is recommended to use a text
editor/environment that can automatically format your source files. For eg,
VS Code or Vim. Moreover, formatting tools can be installed and used separately
to the text editor. 

The [verible](https://chipsalliance.github.io/verible) tools has a linter and
a formatter.

To install it, download the binaries from [their release
page](https://github.com/chipsalliance/verible/releases).

To use:

```
verible-verilog-format --inplace <source files>
```

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

## Commit message guidelines

We adopt this
[guideline](https://gist.github.com/robertpainsi/b632364184e70900af4ab688decf6f53)
for commit messages. 

## Some Recommended Readings

1. [How to ask questions the smart way](http://catb.org/~esr/faqs/smart-questions.html)
2. [How To Become A Hacker](http://vadeker.net/articles/hacker-howto.html)

## Cheatsheet

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

## Links (for quick reference)

1. [Verilog Standard](http://fpgacpu.ca/fpga/verilog.html)
2. [Commit Message Guidelines](https://gist.github.com/robertpainsi/b632364184e70900af4ab688decf6f53)



# Layer wise Debugging Guide
This section provides a comprehensive guide for debugging Gati layer by layer. The steps cover both FPGA and CPU (simulation) environments.



## 1. Compiling ONNX Model to GML

Before debugging, one needs to compile the ONNX model to GML. Use the `gaticc` with the `--dispatch` argument. The exact command can be found in the `gaticc` help manual. The help manual can be accessed with `gaticc -h`. Take a look in the **USAGE: sysim [OPTIONS]** section of the help manual for understanding the required terms, and for examples, refer to the **USAGE EXAMPLES** section.



## 2. Running the Model on FPGA

### Steps for Debugging on FPGA

1. **Specify a Layer for Debugging**
   Use the `--dispatch` argument to define the layer you want to debug. Refer to the `gaticc` help for details about this argument.

2. **Customize Post-Processing**:
   The default `post_imagenet` function only provides the final output. To get intermediate outputs, one must create a custom post-processing function. As we know, a post-processing function is responsible for displaying or providing the desired output of the inference or processed results. When checking intermediate outputs, the following steps are essential:
   - **Understand the Output Structure**: First, analyze and figure out what the output structure looks like at the intermediate stage you are debugging. This could involve understanding the tensor shape, data format, and any specific encoding used.
   - **Create the Function**: Based on the information about the output structure, design a custom function that processes and displays the intermediate output in a meaningful way. This might include reshaping tensors, extracting specific features, or visualizing data.

3. **Find Layer Names**
   Use the `--summary` option in `gaticc` to list the layer names in the model. Instructions for using this option are in the `gaticc` help.

### FPGA Layer Debugging Example

**Example Model Structure:**
```
QuantizeLinear1 --> QLinearConv1 --> DequantizeLinear1 --> Relu --> QuantizeLinear2 --> QLinearConv2
```

If you want to check the output after `QLinearConv1`, pass `QLinearConv1` to the `--dispatch` argument. The FPGA will return the output after processing the layers:
```
DequantizeLinear1 --> Relu --> QuantizeLinear2
```

> Note: In the current FPGA architecture, the `DequantizeLinear` and `QuantizeLinear` layers are fused into a single operation during execution.



## 3. Simulating the Model on CPU

### Debugging on CPU Simulation

1. **Layer Output Behavior**
   On the CPU, the simulation model outputs data directly after the specified layer. For example, passing `QLinearConv1` to the `--dispatch` argument will give the output immediately after `QLinearConv1`.

2. **Comparing FPGA and CPU Outputs**
   To match the outputs from FPGA and CPU simulations, note the difference in behavior:

   - **For FPGA**: Pass `QLinearConv1` will give the output after the operations from `DequantizeLinear1` to `QuantizeLinear2`.
   - **For CPU**: Pass `QuantizeLinear2` to obtain the equivalent output. This ensures consistency between the FPGA and CPU outputs for debugging.

3. **Output File**
   When using the `--dispatch` argument in CPU simulation, the output is saved as a `.npy` file. You can analyze this file or use your own script for further processing based on your needs.


## Comparing Outputs Using --compare-layer

Another option available in `gaticc` for debugging is the `--compare-layer` argument. Details about this option can be found in the `gaticc` help manual.

### How to Use `--compare-layer`

- When running the simulation on the CPU, `gaticc` creates a `.npy` file that stores the tensor output of the required layer.
- During runtime, you can use the `--compare-layer` argument to compare this `.npy` tensor with the dispatched layer output.

### Implementation Details

- The `compare_npy` function in the `src/ml_inference.py` file is responsible for performing this comparison.
- This function compares the `.npy` file with the dispatched layer output to identify any differences.
- one can modify the `compare_npy` function as needed to match your specific debugging requirements.

By using `--compare-layer`, one can easily compare outputs and identify any mismatches between FPGA and CPU simulations during debugging.
