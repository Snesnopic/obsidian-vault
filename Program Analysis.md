
This chapter introduces the fundamental concepts of program analysis, exploring how we can mathematically assign meaning to syntax and systematically reason about program behaviors.

----

## 1. Overview and Motivation

Program analysis is the systematic examination of a program to determine its properties. We apply it for various reasons:

- Finding bugs (historical fun fact: the first "bug" was an actual moth found in the Harvard Mark II in 1947).
    
- Optimizing performance and building compilers.
    
- Detecting security vulnerabilities and improving software maintainability.
    

To check if a program behaves as intended, we must verify if the code satisfies a specific semantic property. However, this is fundamentally constrained by **Rice's Theorem**: there exists no algorithm that can automatically, universally, and exactly determine if a program satisfies a non-trivial semantic property.

Because we cannot have a tool that is simultaneously automatic, universal, and exact, we must rely on different techniques that trade off these traits:

- **Testing:** Unsound (can accept incorrect programs), but complete (does not reject safe programs).
    
- **Machine-Assisted Proving (e.g., Coq, Isabelle):** Sound and quasi-complete, but requires manual effort to supply invariants.
    
- **Finite-State Model Checking:** Automatic, sound, and complete, but only with respect to finite models (can fail to terminate on infinite states).
    
- **Conservative Static Analysis:** Automatic and sound, but incomplete (relies on over-approximation).
    

----

## 2. Formal Semantics and State

Semantics assigns mathematical meaning to syntax. We distinguish between the syntactic representation of a program (how it is written, $c$) and its computed function ($[[c]]$).

- **Memory State:** A state $\sigma$ is a function mapping variables to integers: $\sigma : \mathbb{X} \to \mathbb{Z}$.
    
- **State Space:** The set of all possible states is denoted as $\Sigma \triangleq \{\sigma : \mathbb{X} \to \mathbb{Z}\}$.
    
- **State Update:** The notation $\sigma[n/\mathtt{x}]$ or $\sigma[\mathtt{x} \mapsto n]$ denotes a state identical to $\sigma$, except the variable $\mathtt{x}$ evaluates to $n$.
    

### 2.1 Forward Semantics

For deterministic programs, the denotational semantics models a program as a function from an input state to an output state: $[[c]] : \Sigma \to \Sigma_\bot$.

- The set $\Sigma_\bot = \Sigma \uplus \{\bot\}$ includes a special symbol $\bot$ to represent non-terminating executions.
    

### 2.2 Collecting Semantics

To consider all possible execution trajectories simultaneously (especially useful for non-deterministic programs or abstraction), we lift the semantics to operate on sets of states (the powerset $\wp(\Sigma)$).

- **Collecting Semantics:** $[[c]] : \wp(\Sigma) \to \wp(\Sigma)$.
    
- Defined as: $[[c]]P = \bigcup_{\sigma \in P} [[c]]\sigma$.
    

----

## 3. Approximations

Since exact analysis is impossible due to undecidability, we use approximations.

- **Over-approximations:** Expand the set of possible behaviors. If the over-approximated program doesn't reach a bad state, the exact program won't either.
    
    - _Pro:_ Good for proving correctness (Sound).
        
    - _Con:_ Can report bugs that don't exist (False Positives).
        
- **Under-approximations:** Restrict the set of possible behaviors. If the under-approximated program reaches a bad state, the exact program definitely will.
    
    - _Pro:_ Good for bug-finding.
        
    - _Con:_ Can miss actual bugs (False Negatives).
        

----

## 4. Denotational Semantics of IMP

We construct the meaning of a program compositionally.

### 4.1 Expressions

- **Arithmetic Expressions (Aexp):** $[[\cdot]] : \text{Aexp} \to \Sigma \to \mathbb{Z}$. Example: $[[\mathtt{a}_0 \text{ op } \mathtt{a}_1]]\sigma \triangleq [[\mathtt{a}_0]]\sigma \text{ op } [[\mathtt{a}_1]]\sigma$.
    
- **Boolean Expressions (Bexp):** In collecting semantics, a boolean expression filters a set of states, keeping only those where the condition holds: $[[\cdot]] : \text{Bexp} \to \wp(\Sigma) \to \wp(\Sigma)$. Example: $[[\mathtt{a}_0 \text{ cmp } \mathtt{a}_1]]P \triangleq \{\sigma \in P \mid [[\mathtt{a}_0]]\sigma \text{ cmp } [[\mathtt{a}_1]]\sigma\}$.
    

### 4.2 Commands and Control Flow

Command semantics $[[\cdot]] : \text{Com} \to \wp(\Sigma) \to \wp(\Sigma)$ are defined recursively:

- **Skip:** $[[\mathtt{skip}]]P \triangleq P$.
    
- **Assignment:** $[[\mathtt{x} := a]]P \triangleq \{\sigma[n/\mathtt{x}] \mid \sigma \in P, n = [[a]]\sigma\}$.
    
- **Sequence:** $[[c_1 ; c_2]]P \triangleq [[c_2]]([[c_1]]P)$.
    
- **Choice (Non-determinism):** $[[c_1 + c_2]]P \triangleq [[c_1]]P \cup [[c_2]]P$.
    

### 4.3 Loops and Fixpoints

Loops are handled using the **Kleene Star** operator, which applies a command zero or more times: $[[c^\star]]P \triangleq \bigcup_{k=0}^\infty [[c]]^k P$. To encode a `while` loop, we apply the loop body $c$ as long as condition $b$ holds, and finally filter by $\neg b$:

$$[[\mathtt{while\ b\ do\ c}]]P \triangleq [[\neg b]] \bigcup_{k=0}^\infty ([[c]] \circ [[b]])^k P$$

This represents finding the Least Fixed Point of the semantic function mapping states through iterations of the loop.

----

## 5. Correctness and Preconditions

We use semantic definitions to formally prove if a program starting in a set of input states $P$ will only result in valid output states $Q$.

- **Partial Correctness:** Denoted as $[[c]]P \subseteq Q$. This means that starting from $P$, the execution of $c$ either does not terminate, or terminates in a state satisfying $Q$.
    

To systematically calculate correctness, we compute preconditions:

### 5.1 Dijkstra’s Weakest Liberal Precondition (wlp)

Calculates the largest set of input states from which execution _either_ diverges _or_ ends in $Q$:

$$wlp(c, Q) = \{\sigma \mid [[c]]\{\sigma\} \subseteq Q\}$$

Thus, $[[c]]P \subseteq Q$ if and only if $P \subseteq wlp(c, Q)$.

### 5.2 Backward Semantics and Weakest Possible Precondition (wpp)

Backward semantics reverses the relation: $[[c]]_{op} \triangleq \{(\delta, \sigma) \mid (\sigma, \delta) \in [[c]]\}$. Hoare's Weakest Possible Precondition calculates the largest set of input states that have _at least one successful computation_ reaching $Q$:

$$wpp(c, Q) = \{\sigma \mid [[c]]\sigma \cap Q \neq \emptyset\}$$

Conveniently, this maps directly to the backward semantics: $wpp(c, Q) = [[c]]_{op}Q$.


<div style="page-break-after: always;"></div>

# 02. Denotational Semantics

This chapter formalizes how to assign mathematical meaning to programs, mapping syntax to its computed function. It focuses on collecting semantics, which is the foundation for defining approximations in static analysis.

----

## 1. Preliminaries and State

Semantics assigns meaning to syntax. Given a program written in a specific syntax $c$, its meaning is denoted as $[[c]]$.

- **State ($\sigma$):** A concrete memory state is a function mapping variables to integers, $\sigma : \mathbb{X} \to \mathbb{Z}$.
    
- **State Space ($\Sigma$):** The set of all possible states is $\Sigma \triangleq \{\sigma : \mathbb{X} \to \mathbb{Z}\}$.
    
- **State Update:** The notation $\sigma[n/\mathtt{x}]$ or $\sigma[\mathtt{x} \mapsto n]$ indicates a state identical to $\sigma$, except the variable $\mathtt{x}$ has the value $n$.
    
- **Concrete Domain:** In program analysis, we often work with sets of states. The concrete domain is the powerset of $\Sigma$, denoted as $\wp(\Sigma) \triangleq \{P \mid P \subseteq \Sigma\}$.
    

----

## 2. Semantics of Expressions

Expressions are evaluated relative to a given state or set of states.

### 2.1 Arithmetic Expressions (`Aexp`)

The denotational semantics of an arithmetic expression evaluates to an integer given a specific state: $[[\cdot]] : \text{Aexp} \to \Sigma \to \mathbb{Z}$.

- $[[n]]\sigma \triangleq n$
    
- $[[\mathtt{x}]]\sigma \triangleq \sigma(\mathtt{x})$
    
- $[[\mathtt{a}_0 \text{ op } \mathtt{a}_1]]\sigma \triangleq [[\mathtt{a}_0]]\sigma \text{ op } [[\mathtt{a}_1]]\sigma$
    

### 2.2 Boolean Expressions (`Bexp`)

In collecting semantics, a boolean expression is treated as a filter over a set of states. It returns the subset of states that satisfy the condition: $[[\cdot]] : \text{Bexp} \to \wp(\Sigma) \to \wp(\Sigma)$.

- $[[\text{true}]]P \triangleq P$
    
- $[[\text{false}]]P \triangleq \emptyset$
    
- $[[\mathtt{a}_0 \text{ cmp } \mathtt{a}_1]]P \triangleq \{\sigma \in P \mid [[\mathtt{a}_0]]\sigma \text{ cmp } [[\mathtt{a}_1]]\sigma\}$
    
- $[[\text{not } b]]P \triangleq P \setminus ([[b]]P)$
    

_Note:_ $[[b]]P \subseteq P$ always holds.

----

## 3. Regular Commands and Collecting Semantics

For deterministic programs, semantics can be defined as $[[c]] : \Sigma \to \Sigma_\bot$, where $\Sigma_\bot = \Sigma \uplus \{\bot\}$ handles non-termination. However, to handle non-determinism and lay the groundwork for abstraction, we use **Collecting Semantics**, which maps a set of input states to a set of output states: $[[c]] : \wp(\Sigma) \to \wp(\Sigma)$.

By definition, $[[c]]P = \bigcup_{\sigma \in P} [[c]]\{\sigma\}$.

### 3.1 Base Commands

- **Skip:** $[[\mathtt{skip}]]P \triangleq P$
    
- **Assignment:** $[[\mathtt{x} := a]]P \triangleq \{\sigma[n/\mathtt{x}] \mid \sigma \in P, n = [[a]]\sigma\}$
    
- **Guard/Filter:** $[[b?]]P \triangleq [[b]]P$
    
- **Sequence:** $[[c_1; c_2]]P \triangleq [[c_2]]([[c_1]]P)$
    
- **Non-deterministic Choice:** $[[c_1 + c_2]]P \triangleq [[c_1]]P \cup [[c_2]]P$
    

### 3.2 Loops and Kleene Star

To execute a command an arbitrary number of times, we use the Kleene star operator ($c^\star$).

- $[[c^\star]]P \triangleq \bigcup_{k=0}^\infty [[c]]^k P$
    

This is mathematically resolved using Kleene's fixpoint theorem. The semantics of $[[c^\star]]P$ represents the smallest set of states that contains the initial states $P$ and is closed under the execution of $c$: $[[c^\star]]P = P \cup [[c]]([[c^\star]]P)$

### 3.3 Encoding High-Level Control Flow

Standard control flow constructs are encoded using regular commands:

- **If-Then-Else:** $\mathtt{if\ b\ then\ c_1\ else\ c_2} \triangleq (b?; c_1) + (\neg b?; c_2)$
    
    - Semantics: $[[\mathtt{if\ b\ then\ c_1\ else\ c_2}]]P \triangleq [[c_1]]([[b]]P) \cup [[c_2]]([[\neg b]]P)$
        
- **While Loop:** $\mathtt{while\ b\ do\ c} \triangleq (b?; c)^\star; \neg b?$
    
    - Semantics: $[[\mathtt{while\ b\ do\ c}]]P \triangleq [[\neg b]] \left( \bigcup_{k=0}^\infty ([[c]] \circ [[b]])^k P \right)$
        

----

## 4. Partial Correctness and Preconditions

We formalize correctness by checking if the reachable states conform to a specification.

**Partial Correctness:** Given a set of input states $P$ and admissible outputs $Q$, a program $c$ is partially correct if $[[c]]P \subseteq Q$. This means execution either diverges (does not terminate) or reaches a state in $Q$.

### 4.1 Dijkstra’s Weakest Liberal Precondition (wlp)

The Weakest Liberal Precondition calculates the largest set of input states from which all terminating computations are guaranteed to end in $Q$.

$$wlp(c, Q) = \{\sigma \mid [[c]]\{\sigma\} \subseteq Q\}$$

_Theorem:_ $[[c]]P \subseteq Q \iff P \subseteq wlp(c, Q)$.

### 4.2 Relational and Backward Semantics

Collecting semantics can be equivalently expressed as a relation $[[c]] \subseteq \Sigma \times \Sigma$, where $(\sigma, \delta) \in [[c]]$ means that starting from $\sigma$, state $\delta$ is reachable.

**Backward Semantics:** The opposite relation maps output states back to their possible input states.

$$[[c]]_{op} \triangleq \{(\delta, \sigma) \mid (\sigma, \delta) \in [[c]]\}$$

For example, $[[c_1; c_2]]_{op} \triangleq [[c_1]]_{op} \circ [[c_2]]_{op}$.

### 4.3 Hoare’s Weakest Possible Precondition (wpp)

The Weakest Possible Precondition identifies the largest set of input states that have _at least one_ successful computation ending in $Q$.

$$wpp(c, Q) = \{\sigma \mid [[c]]\{\sigma\} \cap Q \neq \emptyset\}$$

This directly corresponds to applying the backward semantics to the set of target states:

$wpp(c, Q) = [[c]]_{op}Q$.

<div style="page-break-after: always;"></div>

# 03. Total Correctness

This chapter extends the reasoning of Hoare Logic to ensure **termination**. While partial correctness only guarantees the result _if_ the program ends, **Total Correctness** ensures that the program _must_ end and satisfy the postcondition.

----

## 1. Defining Total Correctness

A total correctness assertion is written using square brackets to distinguish it from partial correctness:

$$[P] \ c \ [Q]$$

### 1.1 Formal Definition

The triple $[P] \ c \ [Q]$ is valid (written $\models [P] \ c \ [Q]$) if and only if for every initial state $\sigma$ such that $\sigma \models P$:

1. The execution of command $c$ starting from $\sigma$ **must terminate**.
    
2. The final state $\sigma'$ **must satisfy** the postcondition $Q$ ($\sigma' \models Q$).
    

### 1.2 Relation to Partial Correctness

Total correctness is the conjunction of partial correctness and termination:

$$[P] \ c \ [Q] \iff \{P\} \ c \ \{Q\} \land (\text{termination of } c \text{ from } P)$$

Consequently, proving total correctness is strictly harder than proving partial correctness.

----

## 2. Mathematical Foundations: Well-Founded Relations

To prove termination, especially for loops, we need a way to show that a program cannot run forever. We do this by mapping program states to a set that cannot have infinite decreasing sequences.

### 2.1 Well-Founded Relations

> **Definition:** A binary relation $\prec$ on a set $A$ is **well-founded** if there are no infinite descending chains $a_0 \succ a_1 \succ a_2 \succ \dots$ in $A$.

- **Example (Well-founded):** The set of natural numbers with the standard "less than" relation $(\mathbb{N}, <)$. Any sequence of decreasing natural numbers must eventually hit zero.
    
- **Example (Not well-founded):** The set of integers $(\mathbb{Z}, <)$. One can decrease indefinitely into negative numbers ($0 > -1 > -2 \dots$).
    

### 2.2 Minimal Element Principle

A relation $\prec$ is well-founded if and only if every non-empty subset $Q \subseteq A$ has at least one **minimal element** $m$ (an element such that no $x \in Q$ satisfies $x \prec m$).

----

## 3. Inference Rules for Total Correctness

Most rules for total correctness (Skip, Assignment, Sequence, Conditional) are identical to those in partial correctness because these constructs naturally terminate if their components do. The primary change is the **While Rule**.

### 3.1 The Total While Rule

To prove $[P] \ \mathtt{while} \ b \ \mathtt{do} \ c \ [P \land \neg b]$, we introduce a **Variant** (also called a ranking function) $t$.

$$\frac{\forall z \in A. \ [P \land b \land t = z] \ c \ [P \land t \prec z]}{\vdash [P] \ \mathtt{while} \ b \ \mathtt{do} \ c \ [P \land \neg b]}$$

**Requirements for the Rule:**

- **Invariant:** $P$ must be a valid loop invariant.
    
- **Well-founded Set:** $(A, \prec)$ must be a well-founded relation.
    
- **Variant Decrease:** In each iteration, the value of the expression $t$ must strictly decrease according to $\prec$.
    

Because $t$ decreases in a well-founded set, it cannot decrease forever; therefore, the loop must eventually terminate.

----

## 4. Practical Example: Counting Down

Consider a simple loop that decrements a counter:

$$\mathtt{while} \ (x > 0) \ \mathtt{do} \ x := x - 1$$

1. **Invariant ($P$):** $x \geq 0$.
    
2. **Variant ($t$):** The value of $x$ itself.
    
3. **Well-founded Relation:** $(\mathbb{N}, <)$.
    
4. **Proof Step:** We must show that if the loop executes ($x > 0$), the new value $x'$ satisfies $x' < x$. Since $x' = x - 1$, this holds for all $x > 0$.
    

----

## 5. Weakest Preconditions ($wp$)

In total correctness, Dijkstra's **Weakest Precondition** ($wp$) specifically requires termination, unlike the Weakest Liberal Precondition ($wlp$).

- **Partial Correctness ($wlp$):** $wlp(c, Q) = \{ \sigma \mid [[c]]\sigma \subseteq Q \}$.
    
- **Total Correctness ($wp$):** $wp(c, Q) = \{ \sigma \mid [[c]]\sigma \neq \emptyset \land [[c]]\sigma \subseteq Q \}$.
    

The condition $[[c]]\sigma \neq \emptyset$ explicitly forces the existence of a final state, thereby ensuring termination.



<div style="page-break-after: always;"></div>

# 04. Hoare Logic

This chapter introduces **Axiomatic Semantics** via **Hoare Logic**, a formal system used to reason about the correctness of computer programs by using logical triples.

----

## 1. Hoare Triples

The fundamental unit of reasoning in Hoare Logic is the **Hoare Triple**, which relates a program's behavior to logical assertions about the state before and after its execution.

A triple is written as:

$$\{P\} \ c \ \{Q\}$$

- **$P$ (Precondition):** An assertion that must hold before the execution of command $c$.
    
- **$c$ (Command):** The program or fragment being analyzed.
    
- **$Q$ (Postcondition):** An assertion that is guaranteed to hold after $c$ finishes execution, provided $P$ was initially true.
    

### 1.1 Partial Correctness

Hoare Logic primarily deals with **Partial Correctness**. A triple $\{P\} \ c \ \{Q\}$ is valid (written $\models \{P\} \ c \ \{Q\}$) if:

> For every initial state $\sigma$ that satisfies $P$, if the execution of $c$ starting from $\sigma$ terminates in a final state $\sigma'$, then $\sigma'$ must satisfy $Q$.

_Crucially, partial correctness does not require the program to terminate_. If the program loops forever, the triple is vacuously true.

----

## 2. Inference Rules for Partial Correctness

To prove a triple is valid, we use a set of **Inference Rules** to derive it formally (written $\vdash \{P\} \ c \ \{Q\}$).

### 2.1 Basic Rules

- **Skip Rule:** The state does not change, so the assertion remains the same.
    
    $$\frac{}{\{P\} \ \mathtt{skip} \ \{P\}}$$
    
- **Assignment Rule:** To ensure $P$ holds after $x := a$, it must hold for the expression $a$ beforehand. $P[a/x]$ denotes the substitution of $x$ with $a$ in $P$.
    
    $$\frac{}{\{P[a/x]\} \ x := a \ \{P\}}$$
    

### 2.2 Structural Rules

- **Sequence Rule:** To reason about $c_1; c_2$, we find an intermediate assertion $R$.
    
    $$\frac{\{P\} \ c_1 \ \{R\} \quad \{R\} \ c_2 \ \{Q\}}{\{P\} \ c_1; c_2 \ \{Q\}}$$
    
- **Conditional Rule:** We analyze both branches of an `if` statement.
    
    $$\frac{\{P \land b\} \ c_1 \ \{Q\} \quad \{P \land \neg b\} \ c_2 \ \{Q\}}{\{P\} \ \mathtt{if} \ b \ \mathtt{then} \ c_1 \ \mathtt{else} \ c_2 \ \{Q\}}$$
    

### 2.3 The While Rule and Invariants

Reasoning about loops requires a **Loop Invariant** $P$, a property that holds before, during, and after every iteration of the loop.

$$\frac{\{P \land b\} \ c \ \{P\}}{\{P\} \ \mathtt{while} \ b \ \mathtt{do} \ c \ \{P \land \neg b\}}$$

- If the invariant $P$ is preserved by the body $c$ when $b$ is true, it will still hold when the loop eventually terminates (at which point $b$ is false).
    

### 2.4 Rule of Consequence

This rule allows us to strengthen preconditions or weaken postconditions using standard logic.

$$\frac{P' \implies P \quad \{P\} \ c \ \{Q\} \quad Q \implies Q'}{\{P'\} \ c \ \{Q'\}}$$

----

## 3. Validity vs. Derivability

There is a distinction between a property being "true" in the model and being "provable" in the logic:

- **Validity ($\models \{P\} \ c \ \{Q\}$):** The property holds according to the denotational/operational semantics.
    
- **Derivability ($\vdash \{P\} \ c \ \{Q\}$):** The property can be proven using the inference rules listed above.
    

### 3.1 Soundness and Completeness

- **Soundness:** Every triple we can derive is actually valid.
    
    $$\vdash \{P\} \ c \ \{Q\} \implies \models \{P\} \ c \ \{Q\}$$
    
- **Relative Completeness:** Every valid triple can be derived, assuming we have a perfect oracle for the underlying mathematical logic (e.g., arithmetic).
    
    $$\models \{P\} \ c \ \{Q\} \implies \vdash \{P\} \ c \ \{Q\}$$
    

----

## 4. Practical Application: Verification Conditions

In practice, human experts or automated tools use **Weakest Preconditions ($wp$)** to generate **Verification Conditions (VCs)**.

1. Start with the desired postcondition $Q$.
    
2. Work backward through the program to find the weakest possible precondition.
    
3. Check if the given precondition $P$ implies this weakest precondition.
    

|**Rule**|**Backward Step**|
|---|---|
|**Assignment**|$wp(x := a, Q) = Q[a/x]$|
|**Sequence**|$wp(c_1; c_2, Q) = wp(c_1, wp(c_2, Q))$|


<div style="page-break-after: always;"></div>

# 05. Necessary Condition Logic

This chapter introduces **Necessary Condition Logic (NC Logic)**, which shifts the perspective from forward execution to backward reasoning using **over-approximation**. While Hoare Logic asks "what is guaranteed to happen if we start in $P$?", NC Logic asks "what *must* have been true at the start if we eventually reached $Q$?".

----

## 1. The Core Concept: Backward Over-Approximation

NC Logic is the backward counterpart to Hoare Logic. It is used to find the **necessary conditions** for a specific outcome (e.g., reaching a target state, a bug, or a specific line of code).

### 1.1 Semantic Definition
We denote an NC triple using angle brackets:
$$\langle P \rangle \ c \ \langle Q \rangle$$

This triple is valid if and only if:
$$[[c]]_{op} Q \subseteq P$$

**Meaning:** The set of all initial states that can possibly lead to a state in $Q$ via command $c$ ($[[c]]_{op} Q$) is a subset of $P$. Therefore, starting in $P$ is a *necessary condition* to reach $Q$. If the initial state was not in $P$, it is impossible to reach $Q$.

### 1.2 Comparison with Hoare Logic
* **Hoare Logic (HL):** $\{P\} \ c \ \{Q\} \iff [[c]]P \subseteq Q$ (Forward Over-approximation).
* **NC Logic:** $\langle P \rangle \ c \ \langle Q \rangle \iff [[c]]_{op}Q \subseteq P$ (Backward Over-approximation).

By expanding the definition, $\langle P \rangle \ c \ \langle Q \rangle$ is equivalent to saying: $\forall \sigma, \sigma'. \ (\sigma, \sigma') \in [[c]] \land \sigma' \in Q \implies \sigma \in P$.

---

## 2. Inference Rules for NC Logic

The inference rules for NC Logic are structurally similar to Hoare Logic but are designed to propagate the post-condition $Q$ backwards to find the necessary pre-condition $P$.

### 2.1 Basic Rules
* **Skip:** $$\frac{}{\langle P \rangle \ \mathtt{skip} \ \langle P \rangle}$$
* **Assignment:** The exact set of states that lead to $Q$ after $x := e$ is $Q[e/x]$. Since we are over-approximating, any $P$ that contains $Q[e/x]$ is a valid necessary condition.
    $$\frac{}{\langle Q[e/x] \rangle \ x := e \ \langle Q \rangle}$$

### 2.2 Structural Rules
* **Sequence:** $$\frac{\langle P \rangle \ c_1 \ \langle R \rangle \quad \langle R \rangle \ c_2 \ \langle Q \rangle}{\langle P \rangle \ c_1; c_2 \ \langle Q \rangle}$$
* **Choice (Non-determinism/If-statements):** If $Q$ can be reached via either branch, the necessary condition must account for both possibilities. Thus, we take the union.
    $$\frac{\langle P_1 \rangle \ c_1 \ \langle Q \rangle \quad \langle P_2 \rangle \ c_2 \ \langle Q \rangle}{\langle P_1 \cup P_2 \rangle \ c_1 + c_2 \ \langle Q \rangle}$$

### 2.3 Rule of Consequence
In NC Logic, since $P$ is an over-approximation of the pre-states, we can safely **weaken the precondition** (make it larger) or **strengthen the postcondition** (make it smaller).
$$\frac{P \implies P' \quad \langle P \rangle \ c \ \langle Q \rangle \quad Q' \implies Q}{\langle P' \rangle \ c \ \langle Q' \rangle}$$
*(Note how this is the exact opposite of the Hoare Logic consequence rule).*

----

## 3. Applications

NC Logic is extremely useful in **security analysis and debugging**. If $Q$ represents an exploitation state (e.g., a buffer overflow or unauthorized access), computing $\langle P \rangle \ c \ \langle Q \rangle$ gives us $P$: the conditions that an attacker *must* satisfy to trigger the exploit. If $P$ evaluates to `false`, the bug is unreachable.

<div style="page-break-after: always;"></div>

# 06. Incorrectness Logic

This chapter introduces **Incorrectness Logic (IL)**, a formal system designed for **bug-finding** and proving the **presence of errors** rather than their absence. Unlike Hoare Logic, which uses over-approximation to prove correctness, IL uses **under-approximation** to ensure that every reported bug is a real one (No False Positives).

----

## 1. Motivation: From Verification to Bug-Finding

While Hoare Logic aims to prove that no bad states are reachable, Incorrectness Logic focuses on proving that a specific bad state _is_ reachable.

- **Hoare Logic (Verification):** Focuses on "any accepted program satisfies the property" (Soundness). It is prone to False Positives due to over-approximation.
    
- **Incorrectness Logic (Bug-Finding):** Focuses on "any reported bug is a real bug". It uses under-approximation to avoid False Positives, though it may have False Negatives (missing some bugs).
    

----

## 2. The Incorrectness Triple

The core construct is the **Incorrectness Triple**, which uses square brackets but with a different semantic meaning than Hoare's total correctness:

$$[P] \ c \ [Q]$$

### 2.1 Semantic Definition

An incorrectness triple $[P] \ c \ [Q]$ is valid if and only if:

$$Q \subseteq [[c]]P$$

This means that **every state** in the post-condition $Q$ is **reachable** from at least one state in the pre-condition $P$ after executing command $c$.

### 2.2 Comparison of Triples

- **Hoare (Over-approximation):** $\{P\} \ c \ \{Q\} \iff [[c]]P \subseteq Q$.
    
- **Incorrectness (Under-approximation):** $[P] \ c \ [Q] \iff Q \subseteq [[c]]P$.
    

----

## 3. Inference Rules for Incorrectness Logic

The rules for IL are designed to propagate reachability information forward.

### 3.1 Basic Rules

- **Assignment Rule:** A state reached after an assignment is reachable if the original state was in $P$.
    
    $$\frac{}{[P] \ x := e \ [\{ \sigma[ [ [ e ] ] \sigma / x] \mid \sigma \in P \}]}$$
    
- **Sequence Rule:** Reachability is transitive through sequential execution.
    
    $$\frac{[P] \ c_1 \ [R] \quad [R] \ c_2 \ [Q]}{[P] \ c_1; c_2 \ [Q]}$$
    

### 3.2 Choice and Iteration

- **Choice Rule:** Since IL tracks what _can_ happen, the choice rule takes the union of reachable states from both branches.
    
    $$\frac{[P] \ c_1 \ [Q_1] \quad [P] \ c_2 \ [Q_2]}{[P] \ c_1 + c_2 \ [Q_1 \cup Q_2]}$$
    
- **Iteration (Unrolling):** To find bugs in loops, IL typically explores the loop for a finite number of iterations ($k$).
    
    $$\frac{[P] \ c^k \ [Q]}{[P] \ c^* \ [Q]}$$
    
    If a state is reachable in exactly $k$ steps, it is reachable in the loop.
    

----

## 4. Handling Errors: Real Incorrectness Logic

In real-world analysis, we distinguish between normal termination and error states.

### 4.1 Exit Conditions

An extended triple tracks the "exit status" $\epsilon$ (e.g., `ok` for normal termination, `er` for an error/bug):

$$[P] \ c \ [\epsilon : Q]$$

- **Reachability of Errors:** $[P] \ c \ [\text{er} : Q]$ means every state in $Q$ is an error state reachable from $P$.
    
- **Short-circuiting:** If a command $c_1$ results in an error, the subsequent command $c_2$ in a sequence $c_1; c_2$ is not executed for that specific trajectory.
    

### 4.2 Application to Static Analysis

IL is the foundation for modern "bug-hunting" tools (like **Facebook Infer** or **Meta Zoncolan**). These tools prioritize reporting "True Positives" to avoid "alarm fatigue" among developers.


<div style="page-break-after: always;"></div>

# 07. Sufficient Incorrectness Logic

This chapter introduces **Sufficient Incorrectness Logic (SIL)**. While standard Incorrectness Logic (IL) uses forward under-approximation, SIL uses **backward under-approximation**. It is designed to find conditions that are strictly **sufficient** to trigger a specific state or bug.

----

## 1. The Core Concept: Backward Under-Approximation

SIL is the backward counterpart to Incorrectness Logic. It answers the question: "What starting conditions are *sufficient* to guarantee that a path to $Q$ exists?".

### 1.1 Semantic Definition
We denote a SIL triple using floor brackets (or sometimes a variant of standard brackets depending on the literature convention):
$$\lfloor P \rfloor \ c \ \lfloor Q \rfloor$$

This triple is valid if and only if:
$$P \subseteq [[c]]_{op} Q$$

**Meaning:** Every state in $P$ has at least one valid execution path through $c$ that terminates in $Q$. Therefore, satisfying $P$ is *sufficient* to reach $Q$. 

### 1.2 Symmetry of the Four Logics
To see the complete picture of Program Analysis logics:
1.  **Hoare Logic (HL):** $[[c]]P \subseteq Q$ (Forward Over) - *Absence of bugs.*
2.  **Incorrectness Logic (IL):** $Q \subseteq [[c]]P$ (Forward Under) - *Presence of bugs from P.*
3.  **Necessary Condition (NC):** $[[c]]_{op}Q \subseteq P$ (Backward Over) - *Required conditions to reach Q.*
4.  **Sufficient Incorrectness (SIL):** $P \subseteq [[c]]_{op}Q$ (Backward Under) - *Sufficient conditions to reach Q.*

----

## 2. Inference Rules for SIL

The rules for SIL mirror those of IL but operate in reverse, propagating the post-condition $Q$ backwards to find a sufficient pre-condition $P$.

### 2.1 Basic Rules
* **Skip:** $$\frac{}{\lfloor P \rfloor \ \mathtt{skip} \ \lfloor P \rfloor}$$
* **Assignment:** Since $Q[e/x]$ is the exact set of pre-states, any subset $P$ is a sufficient condition.
    $$\frac{}{\lfloor Q[e/x] \rfloor \ x := e \ \lfloor Q \rfloor}$$

### 2.2 Structural Rules
* **Sequence:** $$\frac{\lfloor P \rfloor \ c_1 \ \lfloor R \rfloor \quad \lfloor R \rfloor \ c_2 \ \lfloor Q \rfloor}{\lfloor P \rfloor \ c_1; c_2 \ \lfloor Q \rfloor}$$
* **Choice (Non-determinism):** Unlike NC Logic which unions preconditions, in SIL, if $P_1$ is sufficient to reach $Q$ through $c_1$, then $P_1$ is already sufficient for the entire choice construct.
    $$\frac{\lfloor P_1 \rfloor \ c_1 \ \lfloor Q \rfloor}{\lfloor P_1 \rfloor \ c_1 + c_2 \ \lfloor Q \rfloor} \quad \text{or} \quad \frac{\lfloor P_2 \rfloor \ c_2 \ \lfloor Q \rfloor}{\lfloor P_2 \rfloor \ c_1 + c_2 \ \lfloor Q \rfloor}$$

### 2.3 Rule of Consequence
Since SIL tracks an under-approximation ($P$ is a subset of the actual pre-states), we can safely **strengthen the precondition** (make it smaller) or **weaken the postcondition** (make it larger).
$$\frac{P' \implies P \quad \lfloor P \rfloor \ c \ \lfloor Q \rfloor \quad Q \implies Q'}{\lfloor P' \rfloor \ c \ \lfloor Q' \rfloor}$$

----

## 3. Applications

SIL is the ultimate tool for **automated exploit generation and test-case generation**. If $Q$ is an assertion failure or a crash, finding a valid SIL triple $\lfloor P \rfloor \ c \ \lfloor Q \rfloor$ means that *any* state satisfying $P$ will definitively trigger the bug. You can plug the constraints of $P$ into an SMT solver (like Z3) to generate a concrete test case that is mathematically guaranteed to crash the program.

<div style="page-break-after: always;"></div>

# 08. Separation Logic

This chapter introduces **Separation Logic (SL)**, an extension of Hoare Logic designed to facilitate reasoning about programs that mutate shared data structures and pointers. It solves the **aliasing problem** that makes standard Hoare Logic cumbersome when dealing with the heap.

----

## 1. The Aliasing Problem and Local Reasoning

In standard Hoare Logic, assigning to a pointer (e.g., `*x = 10`) can inadvertently change the value of other variables if they alias the same memory location (e.g., if `x` and `y` point to the same address). 

Separation Logic introduces **local reasoning**: specifications and proofs can focus *only* on the portion of memory actually used by a command (its footprint). The **Frame Rule** then allows extending this local proof to a broader, global state without worrying about hidden side-effects.

----

## 2. Memory Model: Store and Heap

The state in SL is split into two distinct components:
* **Store (Stack) $s : \text{Var} \to \text{Val}$:** Maps variables to values.
* **Heap $h : \text{Loc} \rightharpoonup \text{Val}$:** A partial function mapping memory locations (addresses) to values.

Two heaps $h_1$ and $h_2$ are **disjoint** (written $h_1 \perp h_2$) if their domains do not overlap ($\text{dom}(h_1) \cap \text{dom}(h_2) = \emptyset$). If they are disjoint, their union $h_1 \uplus h_2$ forms a valid, larger heap.

----

## 3. Assertions in Separation Logic

SL introduces spatial connectives to express properties about the exact geometry of the heap.

### 3.1 Spatial Connectives
* **Empty Heap ($\text{emp}$):** Asserts that the heap is currently empty (contains no allocated locations).
    $$s, h \models \text{emp} \iff \text{dom}(h) = \emptyset$$
* **Points-to ($E \mapsto E'$):** Asserts that the heap contains *exactly one* allocated location, which is the evaluation of $E$, and it holds the value $E'$.
    $$s, h \models E \mapsto E' \iff \text{dom}(h) = \{[[E]]s\} \land h([[E]]s) = [[E']]s$$
* **Separating Conjunction ($P * Q$):** Asserts that the current heap can be split into two *disjoint* sub-heaps, where one satisfies $P$ and the other satisfies $Q$.
    $$s, h \models P * Q \iff \exists h_1, h_2.\ h_1 \perp h_2 \land h = h_1 \uplus h_2 \land (s, h_1 \models P) \land (s, h_2 \models Q)$$
* **Magic Wand / Separating Implication ($P \mathrel{-\mkern-6mu*} Q$):** Asserts that if the current heap is extended with a disjoint heap satisfying $P$, the combined heap will satisfy $Q$.

----

## 4. Inference Rules

SL modifies standard Hoare triples $\{P\} \ c \ \{Q\}$ to enforce a strict **footprint semantics**: $c$ must execute safely (without segmentation faults or accessing unallocated memory) using *only* the memory explicitly described in $P$.

### 4.1 The Frame Rule
The cornerstone of local reasoning in SL. It states that if a program $c$ executes safely in a small heap ($P$), its execution will be identical in a larger heap ($P * R$), leaving the untouched part ($R$) completely unchanged.
$$\frac{\{P\} \ c \ \{Q\}}{\{P * R\} \ c \ \{Q * R\}}$$
*Side condition:* The command $c$ must not modify any variables present in the free variables of $R$.

### 4.2 Heap Manipulation Rules
These commands map directly to low-level memory operations (dereferencing, mutation, dynamic allocation, and deallocation).

* **Allocation (Cons):** Allocates contiguous memory cells.
    $$\frac{}{\{\text{emp}\} \ x := \text{cons}(e_1, \dots, e_n) \ \{x \mapsto e_1 * \dots * x+n-1 \mapsto e_n\}}$$
* **Mutation:** Updates the value at a memory location. The location must be explicitly known to exist in the precondition.
    $$\frac{}{\{E \mapsto -\} \ [E] := E' \ \{E \mapsto E'\}}$$
    *(Note: $E \mapsto -$ means $E$ points to some arbitrary, unconstrained value).*
* **Lookup:** Reads a value from the heap.
    $$\frac{}{\{E \mapsto v\} \ x := [E] \ \{E \mapsto v \land x = v\}}$$
    *(Side condition: $x$ must not appear free in $E$ or $v$).*
* **Deallocation (Dispose):** Frees a memory location. It consumes the points-to assertion, rendering that memory address inaccessible for future operations.
    $$\frac{}{\{E \mapsto -\} \ \text{dispose}(E) \ \{\text{emp}\}}$$

----

## 5. Memory Safety
By design, Separation Logic triples ensure **memory safety**. If $\{P\} \ c \ \{Q\}$ is provable, it is mathematically guaranteed that $c$ will not cause memory faults (like double-freeing or dereferencing a null/dangling pointer) when executed from a state satisfying $P$.

## 6. Inductive Predicates for Data Structures

When dealing with dynamic data structures like linked lists—common in languages with manual memory management—we need a way to describe an arbitrary number of dynamically allocated nodes. Separation Logic handles this elegantly using recursive (inductive) predicates.

### 6.1 Lists and List Segments
To reason about a list, we define what it means for a pointer to hold a list of a certain shape. 

* **List Segment ($ls$):** A list segment from a pointer $x$ to a pointer $y$ represents a chain of nodes starting at $x$ and ending just before $y$.
  $$ls(x, y) \triangleq (x = y \land \text{emp}) \lor (x \neq y \land \exists v, l.\ x \mapsto (v, l) * ls(l, y))$$
  *Base case:* $x$ and $y$ are the same pointer, and the heap is empty.
  *Inductive step:* $x$ points to a node containing a value $v$ and a "next" pointer $l$, and separately ($*$), there is a list segment from $l$ to $y$.

* **Null-Terminated List ($\text{list}$):** A standard linked list is simply a list segment that ends at `nil` (or `null`).
  $$\text{list}(x) \triangleq ls(x, \text{nil})$$

### 6.2 Why Standard Conjunction Fails
Using standard Boolean conjunction ($\land$) to assert that pointers do not alias requires an $O(n^2)$ explosion of inequalities. For three pointers $x, y, z$, we would need:
$x \neq y \land y \neq z \land x \neq z$

If we try to define data structures using $\land$, we cannot guarantee disjointness. For example, claiming a heap satisfies a list starting at $x$ $\land$ a list starting at $y$ does not prevent the two lists from merging or sharing nodes in memory. The separating conjunction ($*$) natively enforces that the memory footprints of the two lists are strictly disjoint: $\text{list}(x) * \text{list}(y)$.

----

## 7. Practical Reasoning with the Frame Rule

Let's look at how local reasoning applies to practical pointer manipulation, such as traversing or mutating a linked list.



### 7.1 Example: List Concatenation
Consider the task of appending a list pointed to by $y$ to the end of a non-empty list pointed to by $x$.

**Code snippet:**
```c
// t traverses the list to find the last node
t := x;
n := [t.next];
while (n != nil) {
    t := n;
    n := [t.next];
}
// append y
[t.next] := y;
````

**Proof Sketch:**

1. **Precondition:** The lists are completely disjoint. $\{ \text{list}(x) * \text{list}(y) \land x \neq \text{nil} \}$
    
2. **Loop Invariant:** As we traverse, we logically split the list $x$ into a processed segment and an unprocessed segment.
    
    $\{ ls(x, t) * t \mapsto (v, n) * \text{list}(n) * \text{list}(y) \}$
    
3. **Loop Exit:** When the loop terminates, $n = \text{nil}$. The invariant becomes:
    
    $\{ ls(x, t) * t \mapsto (v, \text{nil}) * \text{list}(y) \}$
    
4. **Mutation:** The assignment `[t.next] := y` updates the "next" field of the last node to point to $y$. The minimal footprint for this mutation is just $t \mapsto (v, \text{nil})$.
    
    By the mutation axiom: $\{ t \mapsto (v, \text{nil}) \} \ \mathtt{[t.next] := y} \ \{ t \mapsto (v, y) \}$
    
5. **Applying the Frame Rule:** We frame the rest of the lists ($ls(x, t)$ and $\text{list}(y)$) around the local mutation:
    
    $\{ ls(x, t) * t \mapsto (v, \text{nil}) * \text{list}(y) \} \ \mathtt{[t.next] := y} \ \{ ls(x, t) * t \mapsto (v, y) * \text{list}(y) \}$
    
6. **Postcondition:** The resulting spatial layout $ls(x, t) * t \mapsto (v, y) * ls(y, \text{nil})$ exactly matches the definition of $\text{list}(x)$.
    

By defining only the exact memory cell being mutated and framing out the rest, Separation Logic avoids the need to globally verify that the mutation did not corrupt other parts of the data structures.


<div style="page-break-after: always;"></div>

# 09. Incorrectness Separation Logic

This chapter introduces **Incorrectness Separation Logic (ISL)**, which merges the local reasoning of Separation Logic (SL) with the under-approximation principles of Incorrectness Logic (IL). The goal shifts from proving that a program is perfectly safe to systematically and mathematically proving the presence of memory bugs (like memory leaks, use-after-free, and null-pointer dereferences) without yielding false positives.

----

## 1. The Need for ISL

Standard Separation Logic is an over-approximation technique: it guarantees the *absence* of memory safety violations. However, when static analysis tools (like Meta's Infer) report a potential issue based on an over-approximation, it might be a false positive, leading to "alarm fatigue" among developers.

Incorrectness Logic (IL) guarantees that any reported bug is a true bug (under-approximation). By combining IL with the spatial reasoning of SL ($*$), we get **ISL**, which allows bug-finding tools to scale to large codebases by analyzing functions locally and framing out the rest of the memory.

----

## 2. Adapting Separation Logic for Incorrectness

In ISL, we use the incorrectness triple $[P] \ c \ [Q]$, where $P$ and $Q$ now contain spatial assertions. 

### 2.1 The Issue with Deallocation
In standard SL, the `free(x)` (or `dispose(x)`) command consumes the memory cell, leaving an empty heap:
$$\{x \mapsto -\} \ \mathtt{free(x)} \ \{\text{emp}\}$$

If we attempt to use this directly in an under-approximation setting (ISL), we encounter a problem. In IL, we can drop assertions to widen the precondition or shrink the postcondition. If `free(x)` simply results in `emp`, we lose the explicit information that the memory at $x$ was deallocated. If we later try to dereference $x$, the logic might not have enough information to decisively prove an error occurred, leading to false negatives (missing real bugs).

### 2.2 The "Deallocated" Assertion
To solve this, ISL introduces a new spatial assertion to explicitly track freed memory. Instead of simply removing the cell from the domain, we mark it as deallocated (often denoted conceptually as $\text{invalid}(x)$ or $x \mapsto \text{freed}$).

$$[x \mapsto v] \ \mathtt{free(x)} \ [x \mapsto \text{freed}]$$

This is crucial for bug finding:
* **Use-After-Free:** If the current state contains $x \mapsto \text{freed}$ and the command attempts to read or write to $[x]$, the logic definitively transitions to an error state.
* **Double-Free:** If the state contains $x \mapsto \text{freed}$ and the command executes `free(x)`, it definitively triggers an error.



----

## 3. The ISL Frame Rule

The Frame Rule remains the cornerstone for scalability, allowing tools to analyze a small footprint and embed it into a larger context.
$$\frac{[P] \ c \ [\epsilon: Q]}{[P * R] \ c \ [\epsilon: Q * R]}$$
*(where $\epsilon$ is the exit status: `ok` or `er`, and $R$ is untouched by $c$)*

**Compatibility with Freed Memory:**
The separating conjunction ($*$) works seamlessly with the new deallocated assertion. If we have $(x \mapsto \text{freed}) * (y \mapsto v)$, it guarantees that $x$ and $y$ do not alias. Because $x$ is explicitly marked as freed, $y$ must be a valid, distinct allocated cell. 

----

## 4. Real-World Case Study: Vector Reallocation

A classic bug efficiently found by ISL involves dynamic array reallocations, such as using `std::vector::push_back` in C++.

**The Scenario:**
1. A program obtains a pointer `p` to an element inside a vector (e.g., `p = &v[0]`).
2. The program calls `v.push_back(new_element)`.
3. The program attempts to read or write using `p`.

**The Bug (Use-After-Free):**
Under the hood, if the vector's capacity is full, `push_back` will allocate a new, larger memory block, copy the existing elements over, and **free the old memory block**. 
* The pointer `p` still points to the old memory address.
* Because the old block was freed, `p` is now a dangling pointer.
* Dereferencing `p` at step 3 causes a Use-After-Free error.

ISL can mathematically prove this bug exists:
* *Step 1:* State is $p \mapsto v * \text{vector\_rest}$.
* *Step 2:* The `push_back` semantics explicitly output a state where the old footprint is freed: $p \mapsto \text{freed} * \text{new\_vector\_allocation}$.
* *Step 3:* The read operation strictly requires $p \mapsto -$. Since it encounters $p \mapsto \text{freed}$, the derivation forces a transition to the `er` (error) state.

----

## 5. Sufficient Incorrectness Separation Logic

Just as standard IL has a backward counterpart, ISL can be run backwards to yield **Sufficient Incorrectness Separation Logic**. 

Instead of moving forward to see if a bug is reachable, we start from the error state (e.g., the exact line where `p` is dereferenced while pointing to freed memory) and propagate the constraints *backwards*. 

$$\lfloor P \rfloor \ c \ \lfloor \text{er} : Q \rfloor$$

This computes the exact, minimal spatial heap requirements (the Sufficient Condition $P$) that an attacker or fuzzer needs to provide to guarantee the software crashes. Because it uses local reasoning, the analyzer only tracks the pointers involved in the crash, ignoring the thousands of irrelevant memory cells in the global heap.

<div style="page-break-after: always;"></div>

