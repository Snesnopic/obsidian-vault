
# 01. Introduction and Formal Languages

This section introduces the foundational concepts of compilation, formal languages, and automata theory, which form the theoretical basis for Lexical Analysis (Scanning).

----

## 1. Overview of Compilers

A **compiler** is a program that translates an executable program written in a source language into an equivalent program in a target language (often lower-level, such as assembly, machine code, or an intermediate representation like LLVM IR).

### 1.1 Compiler Architecture

Modern compilers are typically divided into three main stages (the "Three-Phase Design"):

1. **Front-End:** Understands the source code. Includes Lexical Analysis (Scanner), Syntax Analysis (Parser), and Contextual/Semantic Analysis (Type Checking). Produces an Intermediate Representation (IR).
    
2. **Optimizer (Middle-End):** Performs IR-to-IR transformations to improve performance, reduce code size, or optimize energy consumption. Involves Dataflow Analysis and Control Flow Analysis.
    
3. **Back-End:** Maps the IR to the target machine. Involves Instruction Selection, Register Allocation, and Instruction Scheduling.
    

----

## 2. Formal Languages Preliminaries

To build a compiler, we must formally define the programming language.

- **Alphabet ($\Sigma$):** A finite set of symbols (e.g., $\Sigma = \{0, 1\}$ or ASCII).
    
- **String:** A finite sequence of symbols from $\Sigma$. The empty string is denoted as $\epsilon$.
    
- **Language ($L$):** A set of strings over a given alphabet. $L \subseteq \Sigma^*$, where $\Sigma^*$ is the Kleene closure of $\Sigma$ (all possible strings including $\epsilon$).
    

### 2.1 Grammars

A generative grammar is defined as a 4-tuple $G = (N, \Sigma, P, S)$:

- $N$: Finite set of non-terminal symbols.
    
- $\Sigma$: Finite set of terminal symbols (disjoint from $N$).
    
- $P$: Finite set of production rules of the form $\alpha \to \beta$.
    
- $S \in N$: The start symbol.
    

### 2.2 The Chomsky Hierarchy

Languages are classified by the restrictiveness of their production rules:

1. **Type 0 (Recursively Enumerable):** Unrestricted grammar. Recognized by Turing Machines.
    
2. **Type 1 (Context-Sensitive):** Productions $\alpha A \beta \to \alpha \gamma \beta$. Recognized by Linear Bounded Automata.
    
3. **Type 2 (Context-Free):** Productions $A \to \gamma$. Recognized by Pushdown Automata (used for Parsing).
    
4. **Type 3 (Regular):** Productions $A \to aB$ or $A \to a$. Recognized by Finite Automata (used for Lexical Analysis).
    

----

## 3. Finite Automata

Finite automata are state machines used to recognize Regular Languages. They consume an input string symbol by symbol and change state.

### 3.1 Deterministic Finite Automata (DFA)

A DFA is a 5-tuple $M = (Q, \Sigma, \delta, q_0, F)$:

- $Q$: Finite set of states.
    
- $\Sigma$: Input alphabet.
    
- $\delta: Q \times \Sigma \to Q$: The transition function. For every state and input symbol, there is exactly one next state.
    
- $q_0 \in Q$: The initial state.
    
- $F \subseteq Q$: The set of final (accepting) states.
    

A string $w$ is accepted if the automaton, starting in $q_0$ and consuming $w$, halts in a state $q_f \in F$.

### 3.2 Non-Deterministic Finite Automata (NFA)

An NFA relaxes the determinism constraints. It is defined as $M = (Q, \Sigma, \delta, q_0, F)$, but the transition function maps to a _set_ of states:

$$\delta: Q \times \Sigma \to \mathcal{P}(Q)$$

An NFA accepts a string if _at least one_ valid computational path leads to an accepting state.

### 3.3 Automata with $\epsilon$-Transitions ($\epsilon$-NFA)

An $\epsilon$-NFA allows transitions without consuming any input symbol.

$$\delta: Q \times (\Sigma \cup \{\epsilon\}) \to \mathcal{P}(Q)$$

**$\epsilon$-closure:** The $\epsilon$-closure of a state $q$, denoted $\epsilon\text{-closure}(q)$, is the set of all states reachable from $q$ using only $\epsilon$-transitions, including $q$ itself.

----

## 4. Equivalences and Regular Expressions

### 4.1 Equivalence of NFA and DFA (Subset Construction)

Every NFA can be converted into an equivalent DFA that recognizes the same language. This is done via the **Subset Construction Algorithm** (also known as Powerset Construction).

Given an NFA $N = (Q_N, \Sigma, \delta_N, q_0, F_N)$, the equivalent DFA $D = (Q_D, \Sigma, \delta_D, \{q_0\}, F_D)$ is constructed as:

- $Q_D = \mathcal{P}(Q_N)$ (Each state in the DFA represents a _set_ of states in the NFA).
    
- $\delta_D(S, a) = \bigcup_{p \in S} \delta_N(p, a)$ for $S \in Q_D$ and $a \in \Sigma$.
    
- $F_D = \{ S \in Q_D \mid S \cap F_N \neq \emptyset \}$.
    

_(Implementation note: In lexer generators like `lex` or `flex` generating C/C++ code, computing the DFA explicit table during generation allows an extremely fast $O(|w|)$ scanning phase, avoiding the runtime overhead of tracking multiple active NFA states)._

### 4.2 Regular Expressions (RE)

Regular expressions are an algebraic way to describe regular languages. The base operators are:

1. **Union ($A \cup B$ or $A + B$):** $L(A) \cup L(B)$
    
2. **Concatenation ($AB$):** $\{ab \mid a \in L(A), b \in L(B)\}$
    
3. **Kleene Star ($A^*$):** Zero or more occurrences of $A$. $\bigcup_{i=0}^\infty A^i$
    

**Kleene's Theorem:** A language is regular if and only if it can be described by a regular expression. Therefore, REs $\equiv$ $\epsilon$-NFAs $\equiv$ NFAs $\equiv$ DFAs.

----

## 5. DFA Minimization

For any regular language, there exists a unique DFA with the minimum number of states.

### 5.1 Distinguishable States and Table-Filling Algorithm

Two states $p$ and $q$ are distinguishable if there exists a string $w$ such that starting from $p$ and reading $w$ leads to an accepting state, while starting from $q$ and reading $w$ leads to a rejecting state (or vice-versa).

**Minimization Algorithm:**

1. Initialize a table marking all pairs $(p, q)$ where $p \in F$ and $q \notin F$ (or vice-versa) as distinguishable.
    
2. Repeat: For any unmarked pair $(p, q)$ and any symbol $a \in \Sigma$, if $(\delta(p,a), \delta(q,a))$ is marked, then mark $(p, q)$.
    
3. Stop when no new pairs can be marked.
    
4. Unmarked pairs are **equivalent** and can be merged into a single state.
    

----

## 6. Proving Languages are NOT Regular: The Pumping Lemma

Not all languages are regular (e.g., $L = \{0^n 1^n \mid n \ge 0\}$ cannot be parsed by a Lexer because an FA has finite memory and cannot "count" arbitrarily high).

**Pumping Lemma for Regular Languages:**

If $L$ is a regular language, there exists an integer $p > 0$ (the pumping length) such that every string $s \in L$ with length $|s| \ge p$ can be partitioned into three pieces, $s = xyz$, satisfying three conditions:

1. $|y| > 0$ (The pumped section is not empty).
    
2. $|xy| \le p$ (The loop occurs within the first $p$ characters).
    
3. For all $i \ge 0$, the string $xy^iz \in L$.
    

To prove a language is _not_ regular, we use the Pumping Lemma in a proof by contradiction, demonstrating that an adversary can pick a string $s \in L$ where _no possible valid partition_ satisfies all three rules simultaneously.

<div style="page-break-after: always;"></div>

# 02. Context-Free Languages and Lexical Analysis
## 1. Lexical Analysis (Scanning)

The Lexical Analyzer (Scanner) is the first phase of the compiler front-end. Its primary job is to read the stream of characters making up the source program and group them into meaningful sequences called **lexemes**. For each lexeme, the scanner produces a **token** of the form:
`⟨token-name, attribute-value⟩`

### 1.1 From Regular Expressions to Code
Lexical analyzers are often generated automatically by tools (like `lex` or `flex`). The generator takes a specification file containing Regular Expressions (RE) associated with semantic actions (usually C/C++ code). 

The compilation process of a scanner is:
1. **RE to $\epsilon$-NFA:** Thompson's Construction.
2. **$\epsilon$-NFA to DFA:** Subset Construction Algorithm.
3. **DFA to Minimized DFA:** Hopcroft's Algorithm (Table-filling).
4. **DFA to Code:** The minimized DFA is encoded as a transition table (a 2D array mapping `State x Character -> Next State`) driven by a simple `while` loop, yielding an $O(|w|)$ scanning phase.

----

## 2. Context-Free Grammars (CFG)

Regular languages cannot express constructs with unbounded nesting (like balanced parentheses or matching `if-else` blocks). To define the syntax of a programming language, we use Context-Free Grammars (Type 2 in the Chomsky Hierarchy).

> **Definition (CFG):**
> A CFG is a 4-tuple $G = (\Sigma, N, S, P)$, where:
> * $\Sigma$: Finite set of terminal symbols (the alphabet/tokens).
> * $N$: Finite set of non-terminal symbols (syntactic variables). $\Sigma \cap N = \emptyset$.
> * $S \in N$: The start symbol.
> * $P$: Finite set of productions of the form $A \to \alpha$, where $A \in N$ and $\alpha \in (\Sigma \cup N)^*$.

### 2.1 Derivations and Parse Trees
A grammar derives strings by repeatedly replacing non-terminals using the production rules.
* **$\Rightarrow$ (Derives in one step):** If $A \to \gamma \in P$, then $\alpha A \beta \Rightarrow \alpha \gamma \beta$.
* **$\Rightarrow^*$ (Derives in zero or more steps):** The reflexive and transitive closure of $\Rightarrow$.

The language generated by $G$ is $L(G) = \{ w \in \Sigma^* \mid S \Rightarrow^* w \}$.

**Parse Tree:** A graphical representation of a derivation. The root is $S$, internal nodes are non-terminals, and leaves are terminals (or $\epsilon$).

### 2.2 Leftmost and Rightmost Derivations
* **Leftmost Derivation:** At each step, the leftmost non-terminal is replaced.
* **Rightmost Derivation:** At each step, the rightmost non-terminal is replaced.

### 2.3 Ambiguity
A grammar is **ambiguous** if it can generate the same string with more than one distinct parse tree (or equivalently, more than one leftmost/rightmost derivation). 
*Ambiguity is fatal for compilers because it implies multiple valid semantic interpretations for the same code.*
To resolve ambiguity, we typically rewrite the grammar to enforce precedence and associativity rules (e.g., separating expressions into `Expr`, `Term`, and `Factor`).

----

## 3. Pushdown Automata (PDA)

A Pushdown Automaton is the computational model equivalent to a CFG. It is essentially an $\epsilon$-NFA augmented with a Stack memory.

### 3.1 Formal Definition
A PDA is defined as $M = (Q, \Sigma, \Gamma, \delta, q_0, Z_0, F)$:
* $Q$: Finite set of states.
* $\Sigma$: Input alphabet.
* $\Gamma$: Stack alphabet.
* $\delta: Q \times (\Sigma \cup \{\epsilon\}) \times \Gamma \to \mathcal{P}(Q \times \Gamma^*)$: Transition function.
* $q_0$: Initial state.
* $Z_0 \in \Gamma$: Initial stack symbol.
* $F \subseteq Q$: Set of final states.


### 3.2 Acceptance Criteria
A PDA can accept a string in two equivalent ways:
1. **Acceptance by Final State:** The automaton consumes all input and ends in a state $q_f \in F$.
2. **Acceptance by Empty Stack:** The automaton consumes all input and leaves the stack empty (useful for proving equivalence with CFGs).

----

## 4. Properties of Context-Free Languages

### 4.1 Closure Properties
Context-Free Languages are **closed** under:
* Union ($L_1 \cup L_2$)
* Concatenation ($L_1 L_2$)
* Kleene Star ($L^*$)

CFLs are **NOT closed** under:
* Intersection ($L_1 \cap L_2$). *However, the intersection of a CFL and a Regular Language is always a CFL.*
* Complement ($\overline{L}$).

### 4.2 The Pumping Lemma for CFGs
Just as finite automata cannot count arbitrarily, PDAs have limitations (they can only compare two quantities using the stack, not three). The Pumping Lemma for CFGs is used to prove that languages like $L = \{ a^n b^n c^n \mid n \ge 0 \}$ are **not** Context-Free.

**Theorem:**
If $L$ is a Context-Free Language, there exists an integer $k > 0$ such that every string $z \in L$ with $|z| \ge k$ can be partitioned into five substrings $z = uvwxy$ satisfying:
1. $|vwx| \le k$ (The pumped section is bounded).
2. $|vx| > 0$ (At least one of $v$ or $x$ is non-empty).
3. For all $i \ge 0$, the string $uv^iwx^iy \in L$.

If an adversary can pick a string $z \in L$ where *no possible valid partition* allows $uv^iwx^iy$ to stay in $L$ for all $i$, then the language is not Context-Free (and thus requires a Context-Sensitive Grammar or a Turing Machine).

<div style="page-break-after: always;"></div>

# 03. Parsing Techniques

This section covers the second fundamental phase of the compiler front-end: Syntax Analysis (Parsing). The parser's job is to take the sequence of tokens produced by the scanner and verify if it can be generated by the Context-Free Grammar (CFG) of the language, simultaneously building a syntax tree (Parse Tree).



----

## 1. Introduction to Parsing

There are two primary approaches to building a parse tree:
1. **Top-Down Parsing:** Builds the tree from the root (start symbol) down to the leaves (the tokens). It attempts to apply productions by expanding the leftmost non-terminal (Leftmost derivation).
2. **Bottom-Up Parsing:** Builds the tree from the leaves up to the root. It attempts to recognize the right-hand sides of productions and reduce them to the left-hand side (Reverse Rightmost derivation).

----

## 2. Top-Down Parsing and FIRST/FOLLOW Sets

Predictive Top-Down parsers (like LL(k)) make decisions on which production to apply by looking at the next $k$ tokens in the input (lookahead). To automate this choice, two fundamental functions are defined on the grammar symbols:

### 2.1 The FIRST Set
`FIRST(\alpha)` is the set of terminals that begin the strings derivable from `\alpha`. 
If `\alpha` can derive the empty string, then $\epsilon$ belongs to `FIRST(\alpha)`.

### 2.2 The FOLLOW Set
`FOLLOW(A)` is the set of terminals that can appear immediately to the right of the non-terminal `A` in any sentential form derived from the start symbol.
* The end-of-file symbol (e.g., `EOF` or `$`) belongs to `FOLLOW(S)`.
* It is used to decide what to do when a production derives $\epsilon$ or when the end of a right-hand side rule is reached. If `FIRST(A)` contains $\epsilon$, the parser considers the symbols in `FOLLOW(A)` to expand `A`.

----

## 3. Bottom-Up Parsing (Shift-Reduce)

Bottom-Up parsing (typically LR) is more powerful than Top-Down and can handle a much larger class of grammars. The algorithm maintains a stack and interacts with the input through two main operations:

1. **Shift:** Takes the current token from the input and pushes it onto the stack.
2. **Reduce:** When the symbols at the top of the stack match the right-hand side (rhs) of a production, they are popped from the stack and replaced with the non-terminal found on the left-hand side (lhs) of the production.



----

## 4. Construction of LR(1) Tables

An LR(1) parser uses a state and a lookahead symbol (1 token) to make optimal parsing decisions. The state of the parser is represented by a set of **Items**. Limited right context is enough to pick the correct actions.

### 4.1 LR(1) Items
An LR(1) item for a production $A \to \beta$ with lookahead $a$ has the form:
$$[A \to B_1 B_2 \bullet B_3, a]$$
The dot ($\bullet$) indicates how much of the production has already been recognized. 
The lookahead symbol serves a critical bookkeeping function to determine reductions:
* In an item with the dot in the middle $[A \to \beta \bullet \gamma, a]$, the lookahead has no direct use for the reduction.
* In an item with the dot at the end $[A \to \beta \bullet, a]$, a lookahead equal to $a$ implies that the parser must perform a reduction using the production $A \to \beta$.

### 4.2 The Canonical Collection Algorithm
To generate the LR(1) parsing table, it is necessary to build the entire canonical collection of sets of LR(1) items (which represent the states of the pushdown automaton).

1. **Initialization:** Start with an augmented grammar by adding a new root production $S' \to S$. Begin with the initial state $s_0$, computing the closure of the first item: 
   $$s_0 \leftarrow \text{closure}([S' \to \bullet S, \text{EOF}])$$
   This step derives all equivalent items by expanding the non-terminals immediately to the right of the dot.

2. **Computing Goto and Reaching a Fixed Point:**
   While the collection of states $S$ is still changing, apply the following process:
   * For each state $s_j \in S$ and for each symbol $X$ (both terminal and non-terminal), compute the transition set $t \leftarrow \text{goto}(s_j, X)$.
   * If the resulting set $t$ is not already in the collection $S$, compute its closure and add it as a new state $s_k$.
   * Record the transition from the source to the destination state: $s_j \xrightarrow{X} s_k$.

<div style="page-break-after: always;"></div>

# 04. Intermediate Representation & Code Shape

This section marks the transition from the front-end to the middle-end of the compiler. We are on the cusp of the art, science, and engineering of compilation. While scanning and parsing are direct applications of automata theory, and context-sensitive analysis is mostly software engineering, the design of the Intermediate Representation (IR) dictates the efficiency of the optimization and code generation phases.

----

## 1. Intermediate Representations (IR)

An IR is an internal structure used by the compiler to represent the source program during translation. A well-designed IR must be expressive enough to capture the source program's semantics but low-level enough to map cleanly to the target architecture.

### 1.1 Structural / Graphical IRs
These IRs represent the code as graphs or trees, ideal for capturing the hierarchical nature of source code.
* **Abstract Syntax Trees (AST):** A tree where internal nodes are operators and leaves are operands. It abstracts away syntactic details (like parentheses).
* **Directed Acyclic Graphs (DAG):** Similar to an AST, but identical subtrees are shared. This explicitly encodes Common Subexpression Elimination (CSE) at the expression level.
* **Control Flow Graphs (CFG):** A directed graph where each node is a **Basic Block** (a maximal sequence of straight-line code with one entry point and one exit point). Edges represent control flow (branches, loops).

### 1.2 Linear IRs
Linear IRs consist of a sequence of instructions executed sequentially, closely resembling low-level machine code (e.g., LLVM IR or ILOC).
* **Three-Address Code (3AC):** Instructions take the form `x = y op z`. Complex expressions are broken down using temporary variables.
* **Static Single Assignment (SSA):** A strict property applied to linear IRs where every variable is defined exactly once. When control flow paths merge, a $\phi$-function (phi-function) is used to multiplex the values (e.g., `x_3 = phi(x_1, x_2)`). This greatly simplifies data-flow analysis.

----

## 2. The Procedure Abstraction

Before generating code, the compiler must establish a standard runtime environment to manage procedure calls, memory allocation, and variable scoping.

### 2.1 Activation Records (Stack Frames)
Every time a function is called, a new Activation Record is pushed onto the call stack. It typically contains:
1. **Actual Parameters:** Arguments passed by the caller.
2. **Return Address:** Where to resume execution in the caller.
3. **Control Link (Dynamic Link):** A pointer to the caller's activation record (used to restore the stack pointer).
4. **Access Link (Static Link):** A pointer to the lexically enclosing environment, necessary to resolve non-local variables in languages with nested scopes.
5. **Saved Registers:** Registers whose values must be preserved across the call.
6. **Local Variables:** Storage for variables declared within the function.

### 2.2 Calling Sequences
The protocol for invoking a procedure is split between the caller and the callee.
* **Prologue:** Code executed at the beginning of the callee to set up its frame pointer, allocate local variables, and save necessary registers.
* **Epilogue:** Code executed at the end of the callee to restore saved registers, place the return value in a standard location, and restore the stack pointer before executing the return jump.

----

## 3. Code Shape

"Code Shape" refers to the specific sequences of IR instructions chosen to implement high-level language constructs. Lowering an AST to an IR requires making concrete choices about memory layout and execution order.

### 3.1 Expressions
Expressions are evaluated by walking the AST (usually in post-order) and generating temporary variables for intermediate results.
*AST for `a + (b * c)` becomes:*
```text
  // lowercase comments kept in english for code clarity
  t1 = b * c
  t2 = a + t1
```

Compilers must carefully manage the types and sizes of operands, particularly when dealing with pointers or low-level type casting (e.g., standard C++ pointer arithmetic implicitly multiplies the offset by `sizeof(type)`).

### 3.2 Boolean Expressions and Control Flow

Booleans can be evaluated in two ways:

1. **Numerical Representation:** `true` is 1, `false` is 0. Operators compute integer values.
    
2. **Short-Circuit Evaluation (Control Flow):** The boolean result is implicit in the control flow. Instead of computing a value, the code jumps to a "true" or "false" branch as soon as the outcome is known.
    
Code shape for an `if-then-else` statement:

```text
  // evaluate condition
  t1 = <condition>
  cbr t1 -> L_then, L_else  // conditional branch
L_then:
  // evaluate then block
  br L_end                  // unconditional branch
L_else:
  // evaluate else block
L_end:
```

### 3.3 Arrays

Array accesses require generating address calculations.

For a 1-dimensional array `A[i]`, the memory address is:

`Address = base_address(A) + (i * element_size)`

For a 2-dimensional array `B[i][j]` (Row-Major order, like in C/C++):

`Address = base_address(B) + ((i * num_columns) + j) * element_size`

### 3.4 Case / Switch Statements

Compilers employ different strategies for `switch` blocks depending on the density of the case values:

- **Sequential `if-else` (Linear Search):** Best for a small number of cases.
    
- **Binary Search:** Best if the cases are sparse but numerous.
    
- **Jump Tables:** If the case values are dense (e.g., 1, 2, 3, 4), the compiler stores code labels in an array and performs an indirect jump in $O(1)$ time: `goto JumpTable[value]`.

<div style="page-break-after: always;"></div>

# 05. Data-Flow Analysis & Fixpoint Theory

This section explores the mathematical frameworks and algorithms used in the middle-end of a compiler to gather information about the program's behavior. This information is crucial for performing safe optimizations.

----

## 1. Approaches to Program Analysis

Program analysis can be performed using various techniques, each differing in focus and semantic foundations. A family of techniques includes:
* **Data Flow Analysis:** Based on the Control Flow Graph (CFG).
* **Constraint Based Analysis:** Extracts inclusions (constraints) from the program flow.
* **Type and Effect Systems:** Uses annotated base types and type constructors.
* **Abstract Interpretation:** A generalized mathematical framework for approximating program semantics.

### 1.1 The Data-Flow Approach
Data-flow analysis constructs an equation system in terms of a specific property at the entry and exit of each node in the CFG. The solution to this system of equations is found by computing a fixpoint (either a least fixpoint or a greatest fixpoint, depending on the approximation direction).


----

## 2. Theoretical Foundations: Fixpoint Theory

To guarantee that our equation systems converge to a solution, we rely on domain theory and partial orders.

### 2.1 Partial Orders and Bounds
A domain $D$ requires a way to compare elements, typically denoted by a partial order relation $\sqsubseteq$. If $x \sqsubseteq y$, it means $x$ is a less precise approximation of $y$, and $y$ is more accurate than $x$.

Given a subset $Q \subseteq S$ in a partially ordered set:
* An element is an **upper bound** if it is greater than or equal to all elements in $Q$.
* The **Least Upper Bound (lub)**, if it exists, is the smallest of all upper bounds. If $Q$ is a finite subset of $\mathbb{N}$ under $\le$, $\text{lub } Q = \max Q$.

### 2.2 Complete Partial Orders (CPO)
A Complete Partial Order (CPO) ensures that iterative approximation processes will converge. We iteratively build a sequence of approximations:
$$x_0 \sqsubseteq x_1 \sqsubseteq x_2 \sqsubseteq \dots \sqsubseteq x_n \sqsubseteq \dots$$
where each step represents a refined analysis state. The process halts when a fixpoint is reached (i.e., $x_k = x_{k+1}$).

----

## 3. Liveness Analysis (Live Variables)

Liveness analysis determines which variables hold values that may be read later in the execution. This is a **backward analysis**.

### 3.1 Definitions
* **Definition (`def[n]`):** An assignment to a variable (L-value usage) in node $n$.
* **Use (`use[n]`):** A usage of a variable's value (R-value usage) in a command.
* **Liveness Property:** A variable $x$ is live along an arc $e \to f$ if there exists a real execution path from $e$ to some node $n$ such that $x \in \text{use}[n]$, and for any intermediate node $n'$, $x \notin \text{def}[n']$.

### 3.2 Data-Flow Equations
The sets are computed iteratively until they stabilize:
* `in[n] = use[n] U (out[n] - def[n])`
* `out[n] = U { in[m] | m \in post[n] }`

### 3.3 Conservative Approximation
In static analysis, "conservative" means erring on the side of safety. In liveness analysis, if $x \in \text{in}[n]$, the variable *could* be live. If $x \notin \text{in}[n]$, it is *definitely dead*. The analysis may erroneously derive that a variable is live, but it is not allowed to erroneously derive that a variable is dead. 
$$\text{in}[n] \supseteq \text{live-in}[n] \quad \text{and} \quad \text{out}[n] \supseteq \text{live-out}[n]$$

----

## 4. Reaching Definitions

This analysis determines which variable definitions (assignments) can reach a given point in the program without being overwritten. This is a **forward analysis**.

### 4.1 Kill and Gen Sets
* `killRD[p]`: The set of all other definitions of a variable $x$ in the program, activated if node $p$ defines $x$.
* `genRD[p]`: The specific definition of $x$ generated at node $p$.

### 4.2 Data-Flow Equations
* For the initial node: `RDentry(p) = {(x, ?) | x \in VARS}`.
* For other nodes: `RDentry(p) = U { RDexit(q) | q \in pre[p] }`.
* Exit state: `RDexit(p) = (RDentry(p) \ killRD[p]) U genRD[p]`.

----

## 5. Available Expressions

Available expressions analysis determines which complex expressions (like `a+b`) have already been computed and not subsequently invalidated by reassignments to their operands. It is used for Common Subexpression Elimination.

### 5.1 Kill and Gen Sets
* `killAE[p]`: An expression $e$ is killed at point $p$ if a variable occurring in $e$ is modified by the command at $p$.
* `genAE[p]`: An expression $e$ is generated at $p$ if it is evaluated in $p$ and no variable in $e$ is modified within $p$.

### 5.2 Data-Flow Equations
Unlike Liveness and Reaching Definitions (which use the Union operator $\cup$), Available Expressions uses the Intersection operator $\cap$ because an expression is available only if it is available along *all* incoming paths.
* `AEentry(p) = \emptyset` (if $p$ is initial).
* `AEentry(p) = \cap { AEexit(q) | q \in pre[p] }` (otherwise).
* `AEexit(p) = (AEentry(p) \ killAE(p)) U genAE(p)`.

<div style="page-break-after: always;"></div>

# 06. Abstract Interpretation & Advanced Static Analysis

This section explores Abstract Interpretation, a generalized mathematical framework for static analysis, and other advanced techniques to approximate program semantics and prove correctness.

----

## 1. Advanced Approaches to Static Analysis

Beyond Data-Flow Analysis, the compiler middle-end can employ other analytical frameworks to gather information about the program:

### 1.1 Constraint-Based Analysis
Instead of solving equations iteratively over a CFG, this approach extracts a number of inclusions (equations or constraints) out of the program. 
* It considers the property at the entry and exit of a node and encodes the information of the flow of the CFG using constraints.
* The analysis is automated by first extracting constraints from the program and then computing the least solution to those constraints.

### 1.2 Type and Effect Systems
This technique relies on annotated base types and annotated type constructors. 
* Statements are assigned types that represent the type of states.
* A specification (annotated type system with axioms and rules) is implemented by extracting constraints and computing their least solution.

----

## 2. Abstract Interpretation Framework

Abstract Interpretation is based on interpreting the program's semantics with abstract values instead of concrete ones. It is used to discern program behavior and prove correctness without executing the code.

### 2.1 Concrete vs. Abstract Domains
* **Concrete Domain:** The actual mathematical space of the program's values. For instance, the concrete domain of sets of integers is defined by the partial order $\langle \mathcal{P}(\mathbb{Z}), \subseteq \rangle$.
* **Abstract Domain:** A simplified mathematical space. For example, a domain capturing only the sign of integers: $A = \{\top, \{+\}, \{-\}, \perp\}$.

### 2.2 Abstraction and Concretization Functions
To map values between domains, we define a Galois Connection using two functions:
1. **Abstraction ($\alpha$):** Maps a concrete set to an abstract value. $\alpha(S) = \cup \{sign(s) \mid s \in S\}$. For example, $\alpha(\{2, 7\}) = \{+\}$ and $\alpha(\{-1, 3\}) = \top$ (where $\top$ means "unknown" or "any sign").
2. **Concretization ($\gamma$):** Maps an abstract value back to a concrete set. $\gamma(X) = \{x \in \mathbb{Z} \mid sign(x) \in X\}$. For example, $\gamma(\top) = \mathbb{Z}$ and $\gamma(\perp) = \emptyset$.

### 2.3 Trace-Based Operational Semantics
A program's operational semantics can be written as a trace updating a program-point and storage-cell pair.
The abstract transition rules are synthesized from the original ones:
$p_i, a \longrightarrow p_j, \alpha(v')$ if $v \in \gamma(a)$ and $p_i, v \longrightarrow p_j, v'$.
This recipe ensures that every transition in the concrete semantics is safely simulated by one in the abstract semantics.

----

## 3. Abstract Operators and Loss of Information

Operations on concrete values must be translated into abstract operations.

### 3.1 Defining Abstract Operations
Consider multiplication over $\mathcal{P}(\mathbb{Z})$: $\{3, 5\} * \{-1, -3\} = \{-3, -9, -5, -15\}$.
In the abstract sign domain, the operator $\times$ is defined as:
* $\{+\} \times \{+\} = \{+\}$ 
* $\{+\} \times \{-\} = \{-\}$ 
* $\{-\} \times \top = \top$ 

### 3.2 The Loss of Precision
Because abstract domains approximate sets of values, performing abstract operations can lead to a loss of information.
* **Concrete evaluation:** $(\{2\} + \{2\}) - \{3\} = \{1\}$ (which corresponds to $\{+\}$).
* **Abstract evaluation:** $(\{+\} + \{+\}) - \{+\} = \{+\} - \{+\} = \top$.
The result $\top$ is sound (it contains $\{1\}$), but imprecise. Due to this loss of precision, the analysis might fail to decide termination for specific inputs.

----

## 4. Correctness, False Alarms, and Domains

The goal of static analysis is to prove that the reachable states of a program (blue area) do not intersect with the error states (red area), meaning blue $\cap$ red = $\emptyset$.

### 4.1 False Positives vs. False Negatives
* **Unsound Analysis:** If an analysis incorrectly claims a state is unreachable when it is actually reachable, it yields a **False Negative**. The program is bugged, but the analysis misses it.
* **Conservative Analysis:** Static analysis must be sound. It over-approximates the reachable states. If the over-approximation intersects with the error states while the concrete states do not, it triggers a **False Positive (False Alarm)**.

### 4.2 Choosing the Right Domain
The choice of abstract domain dictates the precision:
* **Interval Domain:** Approximates variables independently (e.g., $x \in [0, 10]$). It captures rectangular bounding boxes. This can lead to false alarms if the safe region requires relational tracking (green $\cap$ red $\neq \emptyset$).
* **Polyhedra Domain:** Tracks linear relations between variables (e.g., $x + y \le 4$). It captures polygonal shapes and can prove correctness where the interval domain fails (cyan $\cap$ red = $\emptyset$).

----

## 5. Widening ($\nabla$)

When using domains like Intervals or Polyhedra, loops can generate infinite ascending chains of approximations (e.g., an index $i$ growing at each iteration: $[0, 0], [0, 1], [0, 2] \dots$).
To guarantee that the fixpoint computation terminates, Abstract Interpretation introduces the **Widening** operator. 
When the analysis detects that bounds keep growing across loop iterations, the widening operator forces convergence by extrapolating the bound to infinity (e.g., jumping to $\top$ or $[0, +\infty]$).

<div style="page-break-after: always;"></div>

# 07. Register Allocation

Register allocation is one of the most critical phases in a compiler's back-end. The objective is to assign a potentially unbounded number of virtual registers (used in the intermediate representation) to a finite set of physical registers provided by the target processor architecture. The efficiency of this phase heavily dictates the performance of the compiled code, especially in low-level languages.

----

## 1. Static Single Assignment (SSA) Form

To simplify allocation and data-flow analysis, the intermediate representation is typically converted into SSA form. In this form, every variable is defined (assigned) exactly once in the program text.

When the control flow diverges and then merges (e.g., after an `if-else` block), the compiler must resolve the ambiguity of which variable definition is valid. To achieve this, it inserts **$\phi$-functions** (phi-functions).
* At each $\phi$-function, the compiler takes the union of the arguments coming from the converging control flow edges.

## 2. Constructing Live Ranges

To proceed with the actual allocation, the compiler calculates how long each variable "lives" within the program (the period between its definition and its last use).

* Variables must be renamed to accurately reflect these new "live ranges".
* Arguments belonging to the same $\phi$-function must be united together to form a cohesive, continuous live range.
* An example of identifying and grouping live ranges after these unions can be expressed as: `{LRa=a0, LRb=b0, LRc=c0, LRd=d0 d1 d2}`.

## 3. Global Allocation and Graph Coloring

Global register allocation (which operates over the entire Control Flow Graph of a procedure) is typically modeled as a **Graph Coloring** problem, which is known to be NP-complete.



1. **Interference Graph:** An undirected graph is constructed where each node represents a Live Range. An edge exists between two nodes if their Live Ranges "interfere"—meaning they are active (live) simultaneously at some point in the program. Two connected nodes cannot share the same physical register.
2. **Coalescing:** If two Live Ranges do not interfere and are connected by a copy instruction (e.g., `x = y`), their nodes can be merged to safely eliminate the redundant copy instruction.
3. **Spilling:** If the graph requires more "colors" (physical registers) than are available on the architecture, some Live Ranges must be "spilled" (saved to memory, typically on the stack). The compiler inserts load and store instructions, fragmenting the Live Range into smaller, shorter-lived portions, and repeats the coloring process.
4. **Coloring:** Registers (colors) are assigned to nodes such that no two adjacent nodes share the same color.

```cpp
#include <vector>
#include <set>

struct live_range {
    int id;
    std::set<int> interferences;
    int assigned_register = -1;
};

// add interference edge between two live ranges
void add_interference(live_range& a, live_range& b) {
    a.interferences.insert(b.id);
    b.interferences.insert(a.id);
}

// compute coloring for available physical registers
void color_graph(std::vector<live_range>& ranges, int num_physical_regs) {
    // k-coloring algorithm logic
}
```


<div style="page-break-after: always;"></div>

