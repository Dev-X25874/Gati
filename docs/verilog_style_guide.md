# Verilog Coding Style Guide for Vicharak-in

## Basics

### Summary

Verilog a subset of System Verilog is the main logic design language for FPGA Design at Vicharak. 


Verilog and SystemVerilog (often generically referred to as just "Verilog" in
this document) can be written in vastly different styles, which can lead to code
conflicts and code review latency.  This style guide aims to promote Verilog
readability across groups.  To quote the
[Google C++ style guide](https://google.github.io/styleguide/cppguide.html):
"Creating common, required idioms and patterns makes code much easier to
understand."

This guide defines the Comportable style for Verilog. The goals are to:

*   promote consistency across hardware development projects
*   promote best practices
*   increase code sharing and re-use

This style guide defines style for both Verilog-2001 and SystemVerilog compliant
code. Additionally, this style guide defines style for both synthesizable and
test bench code.

## Verilog/SystemVerilog Conventions

### Summary

This section addresses primarily aesthetic aspects of style: line length,
indentation, spacing, etc.

### File Extensions

***Use the `.v` extension for Verilog files (or `.vh` for files
that are included via the preprocessor).***

AND

***Use the `.sv` extension for SystemVerilog files (or `.svh` for files
that are included via the preprocessor).***

File extensions have the following meanings:

*   `.sv` indicates a SystemVerilog file defining a module or package.
*   `.svh` indicates a SystemVerilog header file intended to be included in
    another file using a preprocessor `` `include`` directive.
*   `.v` indicates a Verilog-2001 file defining a module or package.
*   `.vh` indicates a Verilog-2001 header file.

Only `.sv` and `.v` files are intended to be compilation units. `.svh` and `.vh`
files may only be `` `include``-ed into other files.

With exceptions of netlist files, each .sv or .v file should contain only one
module, and the name should be associated. For instance, file `foo.sv` should
contain only the module `foo`.

### General File Appearance

#### Characters

***Use only ASCII characters with UNIX-style line endings(`"\n"`).***

#### POSIX File Endings

***All lines on non-empty files must end with a newline (`"\n"`).***

#### Line Length

***Wrap the code at 80 characters per line.***

The maximum line length for style-compliant Verilog code is 80 characters per
line.

Exceptions:

-   Any place where line wraps are impossible (for example, an include path
    might extend past 80 characters).

[Line-wrapping](#line-wrapping) contains additional guidelines on how to wrap
long lines.

#### No Tabs

***Do not use tabs anywhere.***

Use spaces to indent or align text. See [Indentation](#indentation) for rules
about indentation and wrapping.

To convert tabs to spaces on any file, you can use the
[UNIX `expand`](http://linux.die.net/man/1/expand) utility.

#### No Trailing Spaces

***Delete trailing whitespace at the end of lines.***

### Begin / End

***Use `begin` and `end` unless the whole statement fits on a single line.***

If a statement wraps at a block boundary, it must use `begin` and `end.` Only if
a whole semicolon-terminated statement fits on a single line can `begin` and
`end` be omitted.

&#x1f44d;
```systemverilog {.good}
// Wrapped procedural block requires begin and end.
always_ff @(posedge clk) begin
  q <= d;
end
```

&#x1f44d;
```systemverilog {.good}
// The exception case, where begin and end may be omitted as the entire
// structure fits on a single line.
always_ff @(posedge clk) q <= d;
```

&#x1f44e;
```systemverilog {.bad}
// Incorrect because a wrapped statement must have begin and end.
always_ff @(posedge clk)
  q <= d;
```

`begin` must be on the next line as the preceding keyword, and ends the line.
`end` must start a new line. `end else begin` must be in diffrent line.


&#x1f44e;
```systemverilog {.bad}
// "end else begin" are on the same line.
if (condition) begin
  foo = bar;
end else begin
  foo = bum;
end
```

&#x1f44d;
```systemverilog {.good}
// begin/end are omitted because each semicolon-terminated statement fits on
// a single line.
if (condition) foo = bar;
else foo = bum;
```

&#x1f44d;
```systemverilog {.bad}
// Correct because "else" must not be on the same line as "end".
if (condition) begin
  foo = bar;
end
else begin
  foo = bum;
end
```

&#x1f44d;
```systemverilog {.good}
// An exception is made for labeled blocks.
if (condition) begin : a
  foo = bar;
end : a
else begin : b
  foo = bum;
end : b
```

The above style also applies to individual case items within a case statement.
`begin` and `end` may be omitted if the entire case item (the case expression
and the associated statement) fits on a single line. Otherwise, use the `begin`
keyword on the same line as the case expression.

&#x1f44d;
```systemverilog {.good}
// Consistent use of begin and end for each case item is good.
unique case (state_q)
  StIdle: begin
    state_d = StA;
  end
  StA: begin
    state_d = StB;
  end
  StB: begin
    state_d = StIdle;
    foo = bar;
  end
  default: begin
    state_d = StIdle;
  end
endcase
```

&#x1f44d;
```systemverilog {.good}
// Case items that fit on a single line may omit begin and end.
unique case (state_q)
  StIdle: state_d = StA;
  StA: state_d = StB;
  StB: begin
    state_d = StIdle;
    foo = bar;
  end
  default: state_d = StIdle;
endcase
```

&#x1f44e;
```systemverilog {.bad}
unique case (state_q)
  StIdle:           // These lines are incorrect because we should not wrap
    state_d = StA;  // case items at a block boundary without using begin
  StA:              // and end.  Case items should fit on a single line, or
    state_d = StB;  // else the procedural block must have begin and end.
  StB: begin
    foo = bar;
    state_d = StIdle;
  end
  default: begin
    state_d = StIdle;
  end
endcase
```

### Indentation

***Indentation is two spaces per level.***

Use spaces for indentation. Do not use tabs. You should set your editor to emit
spaces when you hit the tab key.

#### Indented Sections

Always add an additional level of indentation to the enclosed sections of all
paired keywords. Examples of SystemVerilog keyword pairs: `begin / end`,
`module / endmodule`, `package / endpackage`, `class / endclass`,
`function / endfunction`.

#### Line Wrapping

When wrapping a long expression, indent the continued part of the expression by
four spaces, like this:

&#x1f44d;
```systemverilog {.good}
assign zulu = enabled && (
    alpha < bravo &&
    charlie < delta
);

assign addr = addr_gen_function_with_many_params(
    thing, other_thing, long_parameter_name, x, y,
    extra_param1, extra_param2
);

assign structure = '{
    src: src,
    dest: dest,
    default: '0
};
```

Or, if it improves readability, align the continued part of the expression with
a grouping open parenthesis or brace, like this:

&#x1f44d;
```systemverilog {.good}
assign zulu = enabled && (alpha < bravo &&
                          charlie < delta);

assign addr = addr_gen_function(thing, other_thing,
                                long_parameter_name,
                                x, y);

assign structure = '{src: src,
                     dest: dest,
                     default: '0};
```

Operators in a wrapped expression can be placed at either the end or the
beginning of each line, but this must be done consistently within a file.

Open syntax characters such as `{` or `(` that end one line of a multi-line
expression should be terminated with close characters (`}`, `)`) on their
own line. Examples:

&#x1f44d;
```systemverilog {.good}
assign bus_concatenation = {
    bus_valid,
    bus_parity[7:0],
    bus_valid[63:0]
};

inst_type inst_name1 (
  .clk_i       (clk),
  .data_valid_i(data_valid),
  .data_value_i(data_value),
  .data_ready_o(data_ready)
);
```


### Spacing

#### Comma-delimited Lists

***For multiple items on a line, one space must separate the comma and
the next character.***

Additional whitespace is allowed for readability.

&#x1f44d;
```systemverilog {.good}
bus = {addr, parity, data};
a = myfunc(lorem, ipsum, dolor, sit, amet, consectetur, adipiscing, elit,
           rhoncus);
mymodule mymodule(.a(a), .b(b));
```

&#x1f44e;
```systemverilog {.bad}
{parity,data} = bus;
a = myfunc(a,b,c);
mymodule mymodule(.a(a),.b(b));
```

#### Tabular Alignment

Tabular alignment groups two or more similar lines so that the identical parts are directly above one another.
This alignment makes it easy to see which characters are the same and which characters are different between lines.

***The use of tabular alignment is generally encouraged.***

***The use of tabular alignment is required for some constructs as detailed in the corresponding subsection of this guide.***

Constructs which require tabular alignment:

* [Port expressions in module instantiations](#module-instantiation)

Each block of code, separated by an empty line, is treated as separate "table".

Use spaces, not tabs.

For example:

&#x1f44d;
```systemverilog
logic [7:0]  my_interface_data;
logic [15:0] my_interface_address;
logic        my_interface_enable;

logic       another_signal;
logic [7:0] something_else;
```

&#x1f44d;
```systemverilog
mod u_mod (
  .clk_i,
  .rst_ni,
  .sig_i          (my_signal_in),
  .sig2_i         (my_signal_out),
  // comment with no blank line maintains the block
  .in_same_block_i(my_signal_in),
  .sig3_i         (something),

  .in_another_block_i(my_signal_in),
  .sig4_i            (something)
);
```

#### Expressions

***Include whitespace on both sides of all binary operators.***

Use spaces around binary operators. Add sufficient whitespace to aid
readability.

For example:

&#x1f44d;
```systemverilog {.good}
assign a = ((addr & mask) == My_addr) ? b[1] : ~b[0];  // good
```

is better than

&#x1f44e;
```systemverilog {.bad}
assign a=((addr&mask)==My_addr)?b[1]:~b[0];  // bad
```

**Exception:** when declaring a bit vector, it is acceptable to use the compact
notation. For example:

&#x1f44d;
```systemverilog {.good}
wire [WIDTH-1:0] foo;   // this is acceptable
wire [WIDTH - 1 : 0] foo;  // fine also, but not necessary
```

When splitting alternation expressions into multiple lines, use a format that is
similar to an equivalent if-then-else line. For example:

&#x1f44d;
```systemverilog {.good}
assign a = ((addr & mask) == `MY_ADDRESS) ?
           matches_value :
           doesnt_match_value;
```
#### Parameterized Types

***Add one space before type parameters, except when the type is part
of a qualified name.***

A qualified name contains at least one scope `::` operator connecting its
segments. A space in a qualified name would break the continuity of a reference
to one symbol, so it must not be added. Parameter lists must follow the
[space-after-comma](#comma-delimited-lists) rule.

&#x1f44d;
```systemverilog {.good}
my_fifo #(.WIDTH(4), .DEPTH(2)) my_fifo_nibble ...

class foo extends bar #(32, 8);  // unqualified base class
  ...
endclass

foo_h = my_class#(.X(1), .Y(0))::type_id::create("foo_h");  // static method call

my_pkg::x_class#(8, 1) bar;  // package-qualified name
```

&#x1f44e;
```systemverilog {.bad}
my_fifo#(.WIDTH(4), .DEPTH(2)) my_fifo_2by4 ...

class foo extends bar#(32, 8);  // unqualified base class
  ...
endclass

foo_h = my_class #(.X(1), .Y(0))::type_id::create("foo_h");  // static method call

my_pkg::x_class #(8, 1) bar;  // package-qualified name
```

#### Labels

***When labeling code blocks, add one space before and after the colon.***

For example:

&#x1f44d;
```systemverilog {.good}
begin : foo
end : foo
```

&#x1f44e;
```systemverilog {.bad}
end:bar            // There must be a space before and after the colon.
endmodule: foobar  // There must be a space before the colon.
```

#### Case items

There must be no whitespace before a case item's colon; there must be at least
one space after the case item's colon.

The `default` case item must include a colon.

For example:

&#x1f44d;
```systemverilog {.good}
unique case (my_state)
  StInit:   $display("Shall we begin");
  StError:  $display("Oh boy this is Bad");
  default: begin
    my_state = StInit;
    interrupt = 1;
  end
endcase
```

&#x1f44e;
```systemverilog {.bad}
unique case (1'b1)
  (my_state == StError)  : interrupt = 1; // Excess whitespace before colon
  default:begin end                       // Missing space after colon
endcase
```

#### Line Continuation

***It is mandatory to right-align line continuations.***

Aligning line continuations ('`\ `' character) helps visually mark the end of a
multi-line macro. The position of alignment only needs to be beyond the
rightmost extent of a multi-line macro by at least one space, when a space does
not split a token, but should not exceed the maximum line length.

```systemverilog
`define REALLY_LONG_MACRO(arg1, arg2, arg3) \
    do_something(arg1);                     \
    do_something_else(arg2);                \
    final_action(arg3);
```

#### Space Around Keywords

***Include whitespace before and after SystemVerilog keywords.***

Do not include a whitespace:

-   before keywords that immediately follow a group opening, such as an open
    parenthesis.
-   before a keyword at the beginning of a line.
-   after a keyword at the end of a line.

For example:

```systemverilog
// Normal indentation before if.  Include a space after if.
if (foo) begin
end
// Include a space after always, but not before posedge.
always_ff @(posedge clk) begin
end
```

### Parentheses

***Use parentheses to make operations unambiguous.***

In any instance where a reasonable human would need to expend thought or refer
to an operator precedence chart, use parentheses instead to make the order of
operations unambiguous.

#### Ternary Expressions

***Ternary expressions nested in the true condition of another ternary
expression must be enclosed in parentheses.***

For example:

&#x1f44d;
```systemverilog {.good}
assign foo = condition_a ? (condition_a_x ? x : y) : b;
```

While the following nested ternary has only one meaning to the compiler, the
meaning can be unclear and error-prone to humans:

&#x1f44e;
```systemverilog {.bad}
assign foo = condition_a ? condition_a_x ? x : y : b;
```

***Parentheses may be omitted if the code formatting conveys the same
information, for example when describing a priority mux.***

&#x1f44d;
```systemverilog {.good}
assign foo = condition_a ? a :
             condition_b ? b : not_a_nor_b;
```

### Comments

***C++ style comments (`// foo`) are preferred. C style comments
(`/* bar */`) can also be used.***

A comment on its own line describes the code that follows. A comment on a line
with code describes that line of code.

For example:

```systemverilog
// This comment describes the following module.
module foo;
  ...
endmodule : foo

localparam bit ValBaz = 1;  // This comment describes the item to the left.
```

It can sometimes be useful to structure the code using header-style comments in
order to separate different functional parts (like FSMs, the main datapath or
registers) within a module. In that case, the preferred style is a single-line
section name, framed with `//` C++ style comments as follows:

```systemverilog
module foo;

  ////////////////
  // Controller //
  ////////////////
  ...

  ///////////////////////
  // Main ALU Datapath //
  ///////////////////////
  ...

endmodule : foo
```

If the designer would like to use comments to mark the beginning/end of a
particular section for better readability (e.g. in nested for loop blocks), the
preferred way is to use a single-line comment with no extra delineators, as
shown in the examples below.

&#x1f44d;
```systemverilog {.good}
// begin: iterate over foobar
for (...) begin
...
end
// end: iterate over foobar
```

&#x1f44d;
```systemverilog {.good}
for (...) begin // iterate over foobar
...
end // iterate over foobar
```

&#x1f44e;
```systemverilog {.bad}
//-------------------------- iterate over foobar -------------------------------
for (...) begin
...
end
//-------------------------- iterate over foobar -------------------------------
```

&#x1f44e;
```systemverilog {.bad}
///////////////////////////////
// begin iterate over foobar //
///////////////////////////////
for (...) begin
...
end
///////////////////////////////
// end iterate over foobar   //
///////////////////////////////
```


### Declarations

***Signals must be declared before they are used. This means that
implicit net declarations must not be used.***

Within modules, it is **recommended** that signals, types, enums, and
localparams be declared close to their first use. This makes it easier for the
reader to find the declaration and see the signal type. However if you have a habit of declaring them in the start of the module that practice also works one should not declare the signal where it is not supossed to be. 





### Signal Naming Conventions 
#### Suffixes and Prefixes
 
Suffixes and Prefixes are used in several places to give guidance to intent. The following
table lists the suffixes that have special meaning.

| Prefix(es)        | Arena             | Intent         |
| ---               | :---:             | ---            |
|  `i_`             | input port name   | Module inputs  |
| `o_`              | output            | Module Outputs | 
| `io_`             | Bideretion        | Module IO      |
| `w_`              | Wire              | Internal       |
| `r_`               | reg               | Internal       |
 



| Suffix(es)        | Arena | Intent |
| ---               | :---: | ---    |
| `_n`              | signal name | Active low signal |
| `_n`, `_p`        | signal name | Differential pair, active low and active high |
| `_d`, `_q`        | signal name | Input and output of register |
| `_q2`,`_q3`, etc  | signal name | Pipelined versions of signals; `_q` is one cycle of latency, `_q2` is two cycles, `_q3` is three, etc |


When multiple suffixes or/and prefix are necessary use the following guidelines:

* Guidance suffixes and prefix are added together .
* If the signal is active low `_n` will be the first suffix
* If the signal is a module input/output the letters will come last.
* for example a active low rst intput will become `i_rst_n`.


Example:

&#x1f44d;
```systemverilog {.good}
module simple (
  input        i_clk,
  input        i_rst_n,              // Active low reset

  // writer interface
  input [15:0] i_data,
  input        i_valid,
  output       o_ready,

  // bi-directional bus
  inout [7:0]  io_driver,         // Bi directional signal

  // Differential pair output
  output       o_lvds_p,           // Positive part of the differential signal
  output       o_lvds_n            // Negative part of the differential signal
);

  wire w_valid_d, w_valid_q, w_valid_q2, w_valid_q3;
  assign w_valid_d = i_valid; // next state assignment

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      w_valid_q  <= '0;
      w_valid_q2 <= '0;
      w_valid_q3 <= '0;
    end else begin
      w_valid_q  <= w_valid_d;
      w_valid_q2 <= w_valid_q;
      w_valid_q3 <= w_valid_q2;
    end
  end

  assign o_ready = w_valid_q3; // three clock cycles delay

endmodule // simple



```


### File meta data 

*** A meta data section in the starting of a Verilog file that containts some critical information about the verilog module in the file 

This template could be used for this :

```systemverilog

//-----------------------------------------------------------------------------
// Company:         Vicharak Computers PVT LTD
// Engineer:        Deepak Sharda <deepak.sharda@vicharak.in>
// 
// Create Date:     DEC 31, 2024
// Design Name:     xyz
// Module Name:     xyz.sv
// Project:         gati
// Target Device:   Trion T120
// Tool Versions:   Efinix Efinity 2023.2 
// 
// Description: 
//    This module implements ... 
// 
// Dependencies: 
// 
// Version:
//    1.0 - 05/31/2024 -  - Initial release
// 
// Additional Comments: 
//  ... 
// License: 
//    Proprietary © Vicharak Computers PVT LTD - 2024
//-----------------------------------------------------------------------------

```


### Basic Template

***A template that demonstrates many of the items is given below.***

Template:

```systemverilog
//-----------------------------------------------------------------------------
// Company:         Vicharak Computers PVT LTD
// Engineer:        Deepak Sharda <deepak.sharda@vicharak.in>
// 
// Create Date:     DEC 31, 2024
// Design Name:     xyz
// Module Name:     xyz.sv
// Project:         gati
// Target Device:   Trion T120
// Tool Versions:   Efinix Efinity 2023.2 
// 
// Description: 
//    This module implements ... 
// 
// Dependencies: 
// 
// Version:
//    1.0 - 05/31/2024 -  - Initial release
// 
// Additional Comments: 
//  ... 
// License: 
//    Proprietary © Vicharak Computers PVT LTD - 2024
//-----------------------------------------------------------------------------


module my_module #(
  parameter WIDTH = 80,
  parameter HEIGHT = 24
) (
  input              i_clk,
  input              i_rst_n,
  input              i_req_valid,
  input  [WIDTH-1:0] i_req_data,
  output             o_req_ready,
  ...
);

  reg [WIDTH-1:0] r_req_data_masked;

  submodule u_submodule (
    .i_clk,
    .i_rst_n,
    .i_req_valid,
    .i_req_data (req_data_masked),
    .o_req_ready(req_ready),
    ...
  );

  always_comb begin
    req_data_masked = i_req_data;
    case (fsm_state_q)
      ST_IDLE: begin
        req_data_masked = i_req_data & MASK_IDLE;
        ...
  end

  ...

endmodule
```

## Naming

### Summary

| Construct                            | Style                   |
| ------------------------------------ | ----------------------- |
| Declarations (module, class, package, interface) | `lower_snake_case` |
| Instance names                       | `lower_snake_case`      |
| Signals (nets and ports)             | `lower_snake_case`      |
| Variables, functions, tasks          | `lower_snake_case`      |
| Named code blocks                    | `lower_snake_case`      |
| \`define macros                      | `ALL_CAPS`              |
| Tunable parameters for parameterized modules, classes, and interfaces | `ALL_CAPS`  |
| Constants                            | `ALL_CAPS` or `UpperCamelCase` |
| Enumeration types                    | `lower_snake_case_e`    |
| Other typedef types                  | `lower_snake_case_t`    |
| Enumerated value names               | `UpperCamelCase`        |

### Constants

***Declare global constants using parameters in the project package file.***

In this context, **constants** are distinct from tuneable parameters for objects
such as parameterized modules, classes, etc.

Explicitly declare the type for constants.

When declaring a constant:

*   within a package use `parameter`.
*   within a module or class use `localparam`.

The preferred method of defining constants is to declare a `package` and declare
all constants as a `parameter` within that package. If the constants are to be
used in only one file, it is acceptable to keep them defined within that file
rather than a separate package.

Define project-wide constants in the project's main package.

Other packages may also be declared with their own `parameter` constants to
facilitate the creation of IP that may be re-used across many projects.

The preferred naming convention for all immutable constants is to use `ALL_CAPS`, but there are times when the use of `UpperCamelCase` might be considered more natural.

| Constant Type | Style Preference | Conversation |
| ---- | ---- | ---- |
| \`define            | `ALL_CAPS`       | Truly constant |
| module parameter    | `ALL_CAPS`  | truly modifiable by instantiation, not constant |
| derived localparam  | `UpperCamelCase` | while not modified directly, still tracks module parameter |
| tuneable localparam | `ALL_CAPS`  | while not expected to change upon final RTL version, is used by designer to explore the design space conveniently |
| true localparam constant | `ALL_CAPS`  | Example `localparam OP_JALR = 8'hA0;` |
| enum member true constant | `ALL_CAPS` | Example `typedef enum ... { OP_JALR = 8'hA0;` |
| enum set member | `ALL_CAPS` or `UpperCamelCase`     | Example `typedef enum ... { ST_IDLE, ST_FRAME_START, ST_DYN_INSTR_READ ...`, `typedef enum ... { StIdle, StFrameStart, StDynInstrRead...`. A collection of arbitrary values, could be either convention. |

The units for a constant should be described in the symbol name, unless the
constant is unitless or the units are "bits." For example, `FooLengthBytes`.

Example:

&#x1f44d;
```systemverilog {.good}
// package-scope
package my_pkg;

  parameter int unsigned NUM_CPU_CORES = 64;
  // reference elsewhere as my_pkg::NUM_CPU_CORES

endpackage
```
#### Parameterized Objects (modules, etc.)

***Use `parameter` to parameterize, and `localparam` to declare
module-scoped constants. Within a package, use `parameter`.***

You can create parameterized modules, classes, and interfaces to facilitate
design re-use.

Use the keyword `parameter` within the `module` declaration of a parameterized
module to indicate what parameters the user is expected to tune at
instantiation. The preferred naming convention for all parameters is
`UpperCamelCase`. Some projects may choose to use `ALL_CAPS` to differentiate
tuneable parameters from constants.

Derived parameters within the `module` declaration should use `localparam`.
An example is shown below.

```systemverilog
module modname #(
  parameter  int DEPTH  = 2048,         // 8kB default
  localparam int Aw     = $clog2(Depth) // derived parameter
) (
  ...
);

endmodule
```

`` `define`` and `defparam` should never be used to parameterize a module.

Use [package parameters](#constants) to transmit global constants through a
hierarchy instead of parameters. To declare a constant whose scope is internal
to the particular SystemVerilog module, [use `localparam` instead](#constants).

Examples of when to use parameterized modules:

-   When multiple instances of a module will be instantiated, and need to be
    differentiated by a parameter.
-   As a means of specializing a module for a specific bus width.
-   As a means of documenting which global parameters are permitted to change
    within the module.

Explicitly declare the type for parameters.

Use the type of the parameter to help constrain the legal range. E.g. `int
unsigned` for general non-negative integer values, `bit` for boolean values.
Any further restrictions on tuneable parameter values must be documented with
assertions.

Tuneable parameter values should always have reasonable defaults.

For additional reading, see [New Verilog-2001 Techniques for Creating
Parameterized
Models](https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-884-complex-digital-systems-spring-2005/related-resources/parameter_models.pdf).


### Signal Naming

***Use `lower_snake_case` when naming signals.***

In this context, a **signal** is meant to mean a net, variable, or port within a
SystemVerilog design.

Signal names may contain lowercase alphanumeric characters and underscores.

Signal names should never end with an underscore followed by a number (for
example, `foo_1`, `foo_2`, etc.). Many synthesis tools map buses into nets using
that naming convention, so similarly named nets can lead to confusion when
examining a synthesized netlist.

Reserved [Verilog](http://www.xilinx.com/support/documentation/sw_manuals/xilinx13_1/ite_r_verilog_reserved_words.htm) or SystemVerilog keywords may never be used as names.

When interoperating with different languages, be mindful not to use keywords
from other languages.

#### Use descriptive names

***Names should describe what a signal's purpose is.***

Use whole words. Avoid abbreviations and contractions except in the most common
places. Favor descriptive signal names over brevity.


#### Hierarchical consistency

***The same signal should have the same name at any level of the hierarchy.***

A signal that connects to a port of an instance should have the same name as
that port. By proceeding in this manner, signals that are directly connected
should maintain the same name at any level of hierarchy.

Exceptions to this convention are expected, such as:

*   When connecting a port to an element of an array of signals.

*   When mapping a generic port name to something more specific to the design.
    For example, two generic blocks, one with a `host_bus` port and one with a
    `device_bus` port might be connected by a `foo_bar_bus` signal.

In each exceptional case, care should be taken to make the mapping of port names
to signal names as unambiguous and consistent as possible.

### Clocks

***All clock signals must begin with `clk`.***

The main system clock for a design must be named `clk`. It is acceptable to use
`clk` to refer to the default clock that the majority of the logic in a module
is synchronous with.

If a module contains multiple clocks, the clocks that are not the system clock
should be named with a unique identifier, preceded by the `clk_` prefix. For
example: `clk_dram`, `clk_axi`, etc. Note that this prefix will be
used to identify other signals in that clock domain.

### Resets

***Resets are active-low and asynchronous. The default name is `rst_n`.***

Chip wide all resets are defined as active low and asynchronous. Thus they are
defined as tied to the asynchronous reset input of the associated standard
cell registers.

The default name is `rst_n`. If they must be distinguished by their clock, the
clock name should be included in the reset name like `rst_domain_n`.

SystemVerilog allows either of the following syntax styles, but the style
guide prefers the former.

```systemverilog
// preferred
always_ff @(posedge clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
    q <= 1'b0;
  end else begin
    q <= d;
  end
end

// legal but not preferred
always_ff @(posedge clk, negedge i_rst_n) begin
  if (!i_rst_n) begin
    q <= 1'b0;
  end else begin
    q <= d;
  end
end
```

## Language Features for SV

### Preferred SystemVerilog Constructs

Use these SystemVerilog constructs instead of their Verilog-2001 equivalents:

-   `always_comb` is required over `always @*`.
-   `logic` is preferred over `reg` and `wire`.
-   Top-level `parameter` declarations are preferred over `` `define`` globals.


### Package Dependencies

***Packages must not have cyclic dependencies.***

Package files may depend on constants and types in other package files, but
there must not be any cyclic dependencies. That is: if package A depends on a
constant from package B, package B must not depend on anything from package A.
While cyclic dependencies are permitted by the SystemVerilog language
specification, their use can break some tools.

For example:

```systemverilog
package foo;

  // Package "bar" must not depend on anything in "foo":
  parameter int unsigned PageSizeBytes = 16 * bar::Kibi;

endpackage
```

### Module Declaration

***Use the Verilog-2001 full port declaration style, and use the format
below.***

Use the Verilog-2001 combined port and I/O declaration style. Do not use the
Verilog-95 list style. The port declaration in the module statement should fully
declare the port name, type, and direction.

The opening parenthesis should be on the same line as the module declaration,
and the first port should be declared on the following line.

The closing parenthesis should be on its own line, in column zero.

Indentation for module declaration follows the standard indentation
rule of two space indentation.

The clock port(s) must be declared first in the port list, followed by any and
all reset inputs.

Example without parameters:

&#x1f44d;
```systemverilog {.good}
module foo (
  input              i_clk,
  input              i_rst_n,
  input [7:0]        i_d,
  output  [7:0] o_q
);
```

Example with parameters:

&#x1f44d;
```systemverilog {.good}
module foo #(
  parameter int unsigned WIDTH,
) (
  input                    i_clk,
  input                    i_rst_n,
  input [WIDTH-1:0]        i_d,
  output [WIDTH-1:0] o_q
);
```

Do not use Verilog-95 style:

&#x1f44e;
```systemverilog {.bad}
// WRONG:
module foo(a, b, c d);
input wire [2:0] a;
output  b;
...
```

### Module Instantiation

***Use named ports to fully specify all instantiations.***

When connecting signals to ports for an instantiation, use the named port style,
like this:

```systemverilog
my_module i_my_instance (
  .i_clk (i_clk),
  .i_rst_n(i_rst_n),
  .i_d   (from_here),
  .o_q   (to_there)
);
```

If the port and the connecting signal have the same name, you can use the
`.port` syntax (without parentheses) to indicate connectivity. For example:

```systemverilog
my_module i_my_instance (
  .clk_i,
  .rst_ni,
  .i_d (from_here),
  .o_q (to_there)
);
```

All declared ports must be present in the instantiation blocks. Unconnected
outputs must be explicitly written as no-connects (for example:
`.output_port()`), and unused inputs must be explicitly tied to ground (for
example: `.unused_input_port(8'd0)`)

`.*` is not permitted.

Do not use positional arguments to connect signals to ports.

Instantiate ports in the same order as they are defined in the module.

Align port expressions in [tabular style](#tabular-alignment).
Do not include whitespace before the opening parenthesis of the longest port name.
Do not include whitespace after the opening parenthesis, or before the closing parenthesis enclosing the port expression.

:-1:
```systemverilog
mod u_mod(
  .i_clk,
  .i_rst_n,

  // Not allowed: avoid leading/trailing whitespace in expressions.
  .i_sig_1( sig_1 ),
  .i_sig_2( sig_2 )
);

mod u_mod(
  .i_clk,
  .i_rst_n,

  .short_sig_i                       (sig_1),
  // Not allowed: avoid whitespace between the longest signal name and the opening parenthesis.
  .a_very_long_signal_name_indeed_i  (sig_2)
);
```

***Use named parameters for all instantiations.***

When parameterizing an instance, specify the parameter using the named parameter
style. An exception is if there is only one parameter that is obvious such as
register width, then the instantiation can be implicit.

Indentation for module instantiation follows the standard indentation
rule of two space indentation.

```systemverilog
my_module #(
  .HEIGHT(5),
  .WIDTH(10)
) my_module (
  // ...
);

my_reg #(16) my_reg0 (
  .i_clk,
  .i_rst_n,
  .i_d   (data_in),
  .o_q  (data_out)
);
```
Do not specify parameters positionally, unless there is only one parameter and
the intent of that parameter is obvious, such as the width for a register
instance.

Do not use `defparam`.

***Do not instantiate recursively.***

Modules may not instantiate themselves recursively.


### Blocking and Non-blocking Assignments

***Sequential logic must use non-blocking assignments.  Combinational
blocks must use blocking assignments.***

Never mix assignment types within a block declaration.

A sequential block (a block that latches state on a clock edge) must exclusively
use non-block assignments, as defined in the Sequential Logic section below.

Purely combinational blocks must exclusively use blocking assignments.

This is one of Cliff Cumming's [Golden Rules of
Verilog](http://www.ece.cmu.edu/~ece447/s13/lib/exe/fetch.php?media=synth-verilog-cummins.pdf).

### Delay Modeling

***Do not use `#delay` in synthesizable design modules.***

Synthesizable design modules must be designed around a zero-delay simulation
methodology. All forms of `#delay`, including `#0`, are not permitted.

See Cliff Cumming's [Verilog Nonblocking Assignments With Delays, Myths &
Mysteries](http://www.sunburst-design.com/papers/CummingsSNUG2002Boston_NBAwithDelays.pdf)
for detail


### Sequential Logic (Latches)

***The use of latches is discouraged - use flip-flops when possible.***

Unless absolutely necessary, use flops/registers instead of latches.

If you must use a latch, use `always_latch` over `always`, and use non-blocking
assignments (`<=`). Never use blocking assignments (`=`).

### Sequential Logic (Registers)

***Use the standard format for declaring sequential blocks.***

In a sequential always block, only use non-blocking assignments (`<=`). Never
use blocking assignments (`=`).

Designs that mix blocking and non-blocking assignments for registers simulate
incorrectly because some simulators process some of the blocking assignments in
an always block as occurring in a separate simulation event as the non-blocking
assignment. This process makes some signals jump registers, potentially leading
to total protonic reversal. That's bad.

Sequential statements for state assignments should only contain reset values and
a next-state to state assignment, use a separate combinational-only block to
generate that next-state value.

A correctly implemented 8-bit register with an initial value of "0xAB" would be
implemented:

&#x1f44d;
```systemverilog {.good}
logic foo_en;
logic [7:0] foo_q, foo_d;

always_ff @(posedge clk or negedge i_rst_n) begin
  if (!rst_ni) begin
    foo_q <= 8'hab;
  end else if (foo_en) begin
    foo_q <= foo_d;
  end
end
```

Do not allow multiple non-blocking assignments to the same bit.

Example:

&#x1f44e;
```systemverilog {.bad}
if (cond1) begin
  abc <= 4'h1;
end

if (cond2) begin
  abc <= 4'h2;
end
```

If both cond1 and cond2 are true, the Verilog standard says that the second
assignment will take effect, but this is a style violation.

Even if `cond1` and `cond2` are mutually exclusive, make the second `if` into an
`else if`.

Exception: It is fine to set default values first, then specific values.
However, it is preferred to do this work in a separate combinational block with
explicit blocking assignments.

Example:

```systemverilog
always_ff @(posedge clk or negedge rst_ni) begin
  if (!rst_ni) begin
    state_q <= StIdle;
  end else begin
    state_q <= state_d;
  end
end

always_comb begin
  state_d = state_q;    // default assignment next state is present state
  unique case (state_q)
    StIdle: state_d = StInit;       // Idle State move to Init
    StInit: begin                   // Initialize calculation
      if (conditional) begin
        state_d = StIdle;
      end 
      else begin
        state_d = StCalc;
      end
    end
    StCalc: begin                   // Perform calculation
      if (conditional) begin
        state_d = StResult;
      end
    end
    StResult: state_d = Idle;
    default: ;
  endcase
end
```

Keep work in sequential blocks simple. If a sequential block becomes
sufficiently complicated, consider splitting the combinational logic into a
separate combinational (`always_comb`) block. Ideally, sequential blocks should
contain only a register instantiation, with perhaps a load enable or an
increment.

### Don't Cares (`X`'s)

***The use of `X` literals in RTL code is strongly discouraged. RTL must not
assert `X` to indicate "don't care" to synthesis in any case.  In order to flag
and detect invalid conditions, rather than assign and propagate `X` values,
designs should fully define all signal values and make extensive use of SVAs to
indicate the invalid conditions.***

If not strictly controlled, the use of `X` assignments in RTL to flag invalid or
don't care conditions can lead to simulation/synthesis mismatches.

Instead of assigning and propagating `X` in order to flag and detect invalid
conditions, it is encouraged to make **extensive use of SVAs**. The added
benefits of this design practice are that:

- No special code style is required to properly propagate `X` conditions,
- The chance of accidentally introducing simulation/synthesis mismatches is
  systematically reduced,
- Simulation fails quickly and less signal backtracking is needed to root-cause
  bugs,
- In several cases, formal property verification (FPV) can be used to prove
  whether these SVAs can always be fulfilled,
- In a security context, deterministic/defined behavior is desired, even for
  illegal/invalid/unreachable input combinations (sometimes stated more tersely
  as "for security-critical designs, there are no don't-cares").

The solution presented here has similarities with the approaches presented in
["Being Assertive With Your X"](http://www.lcdm-eng.com/papers/snug04_assertiveX.pdf)
by Don Mills.

Note that although don't cares can be used to indicate possible optimization
opportunities to the synthesis tool, it is debatable whether the gains in logic
reduction are significant enough to outweigh the possible simulation/synthesis
mismatch issues that the use of `X` literals may entail (especially with the
gate-counts available in today's technologies).

#### Catching errors where invalid values are consumed

For an internally-generated signal that could be invalid (but not driven to `X`)
and is used to trigger some action (such as a register write-enable), it is
recommened to add an assert to check that when the enable is true, the signal is
valid. This triggers a simple to diagnose failure when an invalid value has been
accidentally used.

```systemverilog

reg r_addr;
reg r_wr_en;

// internal logic which generates reg_addr/reg_wr_en reg_en_addr will never
// be X but must be ignored if reg_wr_en == 0
assign r_addr = ...
assign r_wr_en = ...

...

// trigger some specific action when a certain register is written
reg r_special_en;

assign r_special_en = (r_addr == SPECIAL_REG_ADDR) & r_wr_en;

// Aim to keep RHS of implication as broad as possible
`ASSERT(NoSpecialRegEnWithoutRegEn, r_special_en |-> r_wr_en);
```

Where the value and its validity signal are generated by a DV environment which
will drive `X` on invalid signals an `` `ASSERT_KNOWN `` suffices.

```systemverilog
module mymod (
  input [7:0] i_external_addr,
  input       i_external_wr_en
);

  wire w_special_action_en;

  assign special_action_en =
      (i_external_addr == SPECIAL_ADDR) & i_external_wr_en;

  `ASSERT_KNOWN(w_special_action_en)

endmodule
```

### Combinational Logic

***Avoid sensitivity lists, and use a consistent assignment type.***

Use `always_comb` for SystemVerilog combinational blocks. Use `always @*` if
only Verilog-2001 is supported. Never explicitly declare sensitivity lists for
combinational logic.

Prefer assign statements wherever practical.

Example:

```systemverilog
assign final_value = xyz ? value_a : value_b;
```

Where a case statement is needed, enclose it in its own `always_comb` block.

Synthesizable combinational logic blocks should only use blocking assignments.

Do not use three-state logic (`Z` state) to accomplish on-chip logic such as
muxing.

Do not infer a latch inside a function, as this may cause a
simulation/synthesis mismatch.

### Case Statements

***Avoid case-modifying pragmas. `unique case` is the best
practice. Always define a default case.***

Never use either the `full_case` or `parallel_case` pragmas. These pragmas can
easily cause simulation/synthesis mismatches.

Here is an example of a style-compliant full case statement:

```systemverilog
always_comb begin
  unique casez (select)
    3'b000: operand = accum0 >> 0;
    3'b001: operand = accum0 >> 1;
    3'b010: operand = accum1 >> 0;
    3'b011: operand = accum1 >> 1;
    3'b1??: operand = regfile[select[1:0]];
    default: operand = '0; // assign a default
  endcase
end
```

The `unique` prefix is recommended before all case statements, as it creates
simulation assertions that can catch certain mistakes. In some cases, `priority`
may be used instead of `unique`, though in such cases, cascaded ternary
structures should be the preferred way of representing priority encoders as
they are a more readable representation for priority encoders.

Be sure to use `unique case` correctly. In particular, make sure that:

  - a `default:` statement is **always** included in order to avoid accidental
  inference of latches, even if all cases are covered. In simulation, a case
  expression that evaluates to `X` will not match any case and will behave as a
  latch, leading to different behavior than synthesis if no default is specified.

  - if no default assignments are given before the case statement as shown in
  the example above, any variables assigned in one case item must be assigned in
  all case items, including the `default:`. Failing to do this can lead to a
  simulation/synthesis mismatch as described in [Don Mills' paper][yalagp].

The following is a different example showing a style-compliant case statement
variant that is frequently used for describing the next-state logic of a finite
state machine. What is different from the previous example is that the default
assignments are put before the `unique case` block, thus making it possible to
omit common assignments in the individual cases further below. If it weren't for
the common default assignments before the case statement, all variables would
have to be assigned a value in all cases and in the `default:` in order to
prevent simulation/synthesis mismatches.

```systemverilog
always_comb begin
  // common default assignments
  state_d = state_q;
  outa = 1'b0;
  outb = 1'b0;
  outc = 1'b0;

  unique case (state_q)
    Idle: begin
      state_d = Work;
      outa = in0;
    end
    Work: begin
      state_d = Wait;
      outb = in1;
    end
    Wait: begin
      state_d = Idle;
      outc = in2;
    end
    // always include a default case
    // empty default permissible due to defaults before case block
    default: ;
  endcase
end
```

References:

*   Don Mills, [Yet Another Latch and Gotchas Paper][yalagp]
*   Clifford Cummings, [full\_case parallel\_case, the Evil Twins of Verilog Synthesis][twinevils]
*   Clifford Cummings, [SystemVerilog's priority & unique][priuniq]
*   Sutherland, Mills, and Spear, [Gotcha Again: More Subtleties in the Verilog and SystemVerilog Standards That Every Engineer Should Know][gotagain]

[yalagp]: http://www.lcdm-eng.com/papers/snug12_Paper_final.pdf
[twinevils]: http://www.sunburst-design.com/papers/CummingsSNUG1999Boston_FullParallelCase_rev1_1.pdf
[priuniq]: http://www.sunburst-design.com/papers/CummingsSNUG2005Israel_SystemVerilog_UniquePriority.pdf
[gotagain]: http://www.lcdm-eng.com/papers/snug07_Verilog%20Gotchas%20Part2.pdf

### Generate Constructs

***Always name your generated blocks.***

When using a generate construct, always explicitly name each block of generated
code. Name each possible outcome of the generating if statement, and name the
iterated block of a generating for statement.

This ensures that generated hierarchical signal names are consistent across
different tools.

Generate and all named code blocks should use `lower_snake_case`. A space should
be placed between `begin` and the code block name.

Example of a conditional generate construct:

&#x1f44d;
```systemverilog {.good}
if (TypeIsPosedge) begin : posedge_type
  always_ff @(posedge clk) foo <= bar;
end else begin : negedge_type
  always_ff @(negedge clk) foo <= bar;
end
```

Example of a loop generate construct:

&#x1f44d;
```systemverilog {.good}
for (genvar ii = 0; ii < NumberOfBuses; ii++) begin : my_buses
  my_bus #(.index(ii)) i_my_bus (.foo(foo), .bar(bar[ii]));
end
```

Do not wrap a generate construct with an additional `begin` block.

Do not use generate regions {`generate`, `endgenerate`}.

### Signed Arithmetic

***Use the available signed arithmetic constructs wherever signed
arithmetic is used.***

When it's necessary to convert from unsigned to signed, use the `signed'` cast
operator (`$signed` in Verilog-2001).

If any operand in a calculation is unsigned, Verilog implicitly casts all
operands to unsigned and generates a warning. There should not be any
signed-to-unsigned warnings from either the simulation or synthesis tools if all
unsigned variables are properly casted.

Example of implicit signed-to-unsigned casting:

```systemverilog
logic signed [7:0]  a;
logic               incr;
logic signed [15:0] sum1, sum2, sum3;
initial begin
  a = 8'sh80;                        // a = -128
  incr = 1'b1;
  sum1 = a + incr;                   // bad:  sum1 = 16'h0081 ( 129)
  sum2 = a + signed'({1'b0, incr});  // good: sum2 = 16'hFF81 (-127)
  sum3 = a + 8'sh01;                 // good: sum3 = sum2 (more straightforward)
end
```

In the above example, the fact that `incr` is unsigned causes `a` to be
evaluated as unsigned as well. The `sum1` evaluation is surprising and is
flagged by a warning that should not be ignored.

### Number Formatting

***Prefix printed binary numbers with `0b`. Prefix printed hexadecimal
numbers with `0x`. Do not use prefixes for decimal numbers.***

When formatting text representations of numbers for log files, make it clear
what data you are including.

Make the base of a printed number clear. Only print decimal numbers without
modifiers. Use a `0x` prefix for hexadecimal and `0b` prefix for binary.

Decode individual fields of large structures individually, instead of expecting
the user to manually decode raw values.

&#x1f44d;
```systemverilog {.good}
$display("0x%0x", some_hex_value);
$display("0b%0b", some_binary_value);
$display("%0d",   some_decimal_value);
```

&#x1f44e;
```systemverilog {.bad}
$display("%0x",   some_hex_value);
$display("%0b",   some_binary_value);
$display("0d%0d", some_decimal_value);
```

When assigning constant values, it is preferred to use underscore notation for
hex or binary bit strengths of length beyond 8 for better readability. Zero
prepending is not required unless it improves readability. Declare constants in
the format (binary, hex, decimal) they are typically displayed in.


&#x1f44d;
```systemverilog {.good}
logic [15:0] val0, val1, val2;
logic [39:0] addr0, addr1;

always_comb begin
  val0 = 16'h0;
  if (condition1) begin
    val1  = 16'b0010_0011_0000_1101;
    val2  = 16'b0010_1100_0000_0000;
    addr1 = 40'h00_1fc0_0000;
    addr2 = 40'h00_efc0_0000;
  end else begin
    val0  = 16'hffff;
    val1  = 16'b1010_0011_0110_1001;
    val2  = 16'b1110_1100_1111_0110;
    addr1 = 40'h40_8000_0000;
    addr2 = 40'h41_c000_0000;
  end
end
```

#### Hierarchical references

The use of hierarchical references in synthesizable RTL code is prohibited.
Certain synthesis tools indeed support hierarchical references, while some
tools error out and others may silently ignore them potentially leading to
simulation/synthesis mismatches.

An exemption to this is the case where the hierarchical references are guarded
by macros to remove them for synthesis, e.g., as part of SystemVerilog
assertions (SVAs).

&#x1f44e;
```systemverilog {.bad}

module mymod_int (
  input        i_in0,
  input        i_in1,
  input        i_in2,
  output logic o_out
);

  logic int;
  assign int   = i_in0 & i_in1;
  assign o_out = i_in2 | int;

endmodule

module mymod (
  ...
);

  mymod_int u_mymod_int (
    .i_in0,
    .i_in1,
    .i_in2,
    .o_out
  );

  // Hierarchical references are prohibited in synthesizable RTL code.
  assign o_int = u_mymod_int.int;

endmodule
```
### Logical vs. Bitwise

***Prefer logical constructs for logical comparisons, bit-wise for data.***

Logical operators (`!`, `||`, `&&`, `==`, `!=`) should be used for all
constructs that are evaluating logic (true or false) values, such as
if clauses and ternary assignments.  Prefer bit-wise operators (`~`, `|`,
`&`, `^`) for all data constructs, even if scalar. Exceptions can be made
where it is clear that the evaluated expression is to be used in a logical
context.

:+1:
```systemverilog {.good}
always_ff @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
    reg_q <= '0;
  end else begin
    reg_q <= reg_d;
  end
end

always_comb begin
  if (bool_a || (bool_b && !bool_c) begin
    x = 1'b1;
  end else begin
    x = 1'b0;
end

assign z = ((bool_a != bool_b) || bool_c) ? a : b;
assign y = (a & ~b) | c;
```

:-1:
```systemverilog {.bad}
always_ff @(posedge clk_i or negedge rst_ni) begin
  if (~rst_ni) begin
    reg_q <= '0;
  end else begin
    reg_q <= reg_d;
  end
end

always_comb begin
  if (bool_a | (bool_b & ~bool_c) begin
    x = 1'b1;
  end else begin
    x = 1'b0;
end

assign z = ((bool_a ^ bool_b) | bool_c) ? a : b;
assign y = (a && !b) || c;
```

:+1:
```systemverilog
// allowed logical assignment for boolean test
assign request_valid = !fifo_empty && data_available;

always_comb begin
  if (request_valid) begin
    output_valid = 1'b1;
  end else begin
    output_valid = 1'b0;
  end
end
```

### Finite State Machines

***State machines use an localparam to define states, and be implemented with
two process blocks: a combinational block and a clocked block.***

*** However its better to use enum to define states, and be implemented with
two process blocks: a combinational block and a clocked block.***

Every state machine description has three parts:

1.  An local that declares and describes the states.
1.  A combinational process block that decodes state to produce next state and
    other combinational outputs.
1.  A clocked process block that updates state from next state.

*Enumerating States*

The enum statement for the state machine should list each state in the state
machine. Comments describing the states should be deferred to case statement in
the combinational process block, below.

States should be named in `UpperCamelCase`, like other
[local param](#enumerations).

Barring special circumstances, the initial idle state of the state
machines will be named `Idle` or `StIdle`. (Alternate names are acceptable
if they improve clarity.)

Ideally, each module should only contain one state machine. If your module needs
more than one state machine, you will need to add a unique prefix (or suffix) to
the states of each state machine, to distinguish which state is associated with
which state machine. For example, a module with a "reader" machine and a
"writer" machine might have a `StRdIdle` state and a `StWrIdle` state.

*Combinational Decode of State*

The combinational process block should contain:

-   A case statement that decodes state to produce next state and combinational
    outputs. For clarity, only cases where the output value deviates from the
    default should be coded.
-   Before the case statement should be a block of code that defines default
    values for every combinational output, including "next state."
-   The default value for the "next state" variable should be the current state.
    The case statement that decodes state will then only assign to "next state"
    when transitioning between states.
-   Within the case statement, each state alternative should be preceded with a
    comment that describes the function of that state within the state machine.

*The State Register*

No logic except for reset should be performed in this process. The state
variable should latch the value of the "next state" variable.

*Other Guidelines*

When possible, try to choose state names that differ near the beginning of their
name, to make them more readable when viewing waveform traces.

*Example*

&#x1f44d;
```systemverilog {.good}
// Define the states
localparam = StIdle, StFrameStart, StDynInstrRead, StBandCorr, StAccStoreWrite, StBandEnd ;

// However its better to use the enum 
typedef enum {
  StIdle, StFrameStart, StDynInstrRead, StBandCorr, StAccStoreWrite, StBandEnd
} alcor_state_e;

alcor_state_e alcor_state_d, alcor_state_q;

// Combinational decode of the state
always_comb begin
  alcor_state_d = alcor_state_q;
  foo = 1'b0;
  bar = 1'b0;
  bum = 1'b0;
  unique case (alcor_state_q)
    // StIdle: waiting for frame_start
    StIdle:
      if (frame_start) begin
        foo = 1'b1;
        alcor_state_d = StFrameStart;
      end
    // StFrameStart: Reset accumulators
    StFrameStart: begin
      // ... etc ...
    end
    // may be empty or used to catch parasitic states
    default: alcor_state_d = StIdle;
  endcase
end

// Register the state
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    alcor_state_q <= StIdle;
  end else begin
    alcor_state_q <= alcor_state_d;
  end
end
```

### Active-Low Signals

***The `_n` suffix indicates an active-low signal.***

If active-low signals are used, they must have the `_n` suffix in their
name. Otherwise, all signals are assumed to be active-high.

### Differential Pairs

***Use the `_p` and `_n` suffixes to indicate a differential pair.***

For example, `in_p` and `in_n` comprise a differential pair set.

### Delays

***Signals delayed by a single clock cycle should end in a `_q` suffix.***

If one signal is only a delayed version of another signal, the `_q` suffix
should be used to indicate this relationship.

If another signal is then delayed by another clock cycle, the next signal should
be identifed with the `_q2` suffix, and then `_q3` and so on.

Example:

```systemverilog
always_ff @(posedge clk) begin
  data_valid_q <= data_valid_d;
  data_valid_q2 <= data_valid_q;
  data_valid_q3 <= data_valid_q2;
end
```

## Appendix - Condensed Style Guide

This is a short summary of the Comportable style guide. Refer to the main text
body for explanations examples, and exceptions.

### Basic Style Elements

* Use SystemVerilog-2012 conventions, files named as module.sv, one file
  per module
* Only ASCII, **100** chars per line, **no** tabs, **two** spaces per
  indent for all paired keywords.
* C++ style comments `//`
* For multiple items on a line, **one** space must separate the comma
  and the next character
* Include **whitespace** around keywords and binary operators
* **No** space between case item and colon, function/task/macro call
  and open parenthesis
* Line wraps should indent by **four** spaces
* `begin` must be on the same line as the preceding keyword and end
  the line
* `end` must start a new line

### Construct Naming

* Use **lower\_snake\_case** for instance names, signals, declarations,
  variables, types
* Use **UpperCamelCase** for tunable parameters, enumerated value names
* Use **ALL\_CAPS** for constants and define macros
* Main clock signal is named `clk`. All clock signals must start with `clk_`
* Reset signals are **active-low** and **asynchronous**, default name is
  `rst_n`
* Signal names should be descriptive and be consistent throughout the
  hierarchy

### Suffixes for signals and types

* Add `i_` to module inputs, `o_` to module outputs or `io_` for
  bi-directional module signals
* The input (next state) of a registered signal should have `_d` and
  the output `_q` as suffix
* Pipelined versions of signals should be named `_q2`, `_q3`, etc. to
  reflect their latency
* Active low signals should use `_n`. When using differential signals use
  `_p` for active high
* Enumerated types should be suffixed with `_e`
* Multiple suffixes will not be separated with `_`. `n` should come first
  `i`, `o`, or `io` last

### Language features

* Use **full port declaration style** for modules, any clock and reset
  declared first
* Use **named parameters** for instantiation, all declared ports must
  be present, no `.*`
* Top-level parameters is preferred over `` `define`` globals
* Use **symbolically named constants** instead of raw numbers
* Local constants should be declared `localparam`, globals in a separate
  **.svh** file.
* `logic` is preferred over `reg` and `wire`, declare all signals
  explicitly for SV
* `always_comb`, `always_ff` and `always_latch` are preferred over `always`
* Interfaces are discouraged
* Sequential logic must use **non-blocking** assignments
* Combinational blocks must use **blocking** assignments
* Use of latches is discouraged, use flip-flops when possible.
* The use of `X` assignments in RTL is strongly discouraged, make use of SVAs
  to check invalid behavior instead.
* Prefer `assign` statements wherever practical.
* Use `unique case` and always define a `default` case
* Use available signed arithmetic constructs wherever signed arithmetic
  is used
* When printing use `0b` and `0x` as a prefix for binary and hex. Use
  `_` for clarity
* Use logical constructs (i.e `||`) for logical comparison, bit-wise
  (i.e `|`) for data comparison
* Bit vectors and packed arrays must be little-endian, unpacked arrays
  must be big-endian
* FSMs: **no logic** except for reset should be performed in the process
  for the state register
* A combinational process should first define **default value** of all
  outputs in the process
* Default value for next state variable should be the current state



## Language features

* It is always recommended to use the system verilog for writing your design as most of the EDA tools supports it now and it comes with featueres that makes our job easier and synthesizes better RTL. However we understand that it shift will take time so its recommende to start writing your new designes in SV from now on and you will realized there in not much diffrence after all. 

* The various white papers written by Clifford Cummings are Must Read for Desiging your RTL these are linked ["Here"](http://www.sunburst-design.com/papers/#papers_top)

* It is recommended to go throught these paper at your pace and start using these standard in your design.
