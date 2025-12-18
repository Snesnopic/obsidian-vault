### Part 1: Logic, Unification & Induction

_Logical and algorithmical foundations.._

- What is a signature $\Sigma$?
    
- What is a term over a signature?
    
- What is a substitution?
    
- What is the instantiation order on substitutions?
    
- What is the Unification Problem?
    
- What is a Most General Unifier (MGU)?
    
- Describe the Unification Algorithm (Martelli-Montanari or Robinson).
    
- What is a Logical System?
    
- What is a derivation rule and a derivation tree?
    
- What is a goal-oriented derivation?
    
- What is a well-founded relation?
    
- What is the Principle of Well-Founded Induction?
    
- What is Structural Induction?
    
- **What is Rule Induction?** (Cruciale: usata per tutto il resto del corso)
    
- How to prove properties of the operational semantics using Rule Induction?
    

### Part 2: IMP & Operational Semantics

_Base imperative language._

- What is the syntax of IMP?
    
- What is the configuration of a small-step semantics?
    
- What are the rules of the Small-Step Operational Semantics of IMP?
    
- What are the rules of the Big-Step Operational Semantics of IMP?
    
- What is the difference between small-step and big-step?
    
- How to prove termination of arithmetic expressions?
    
- How to prove determinacy of commands?
    
- Which rule allows proving the divergence of a command?
    
- What is the definition of Program Equivalence based on operational semantics?
    

### Part 3: Orders, Fixpoints & Domain Theory

_Math for denotational semantics._

- What is a Partial Order (PO)?
    
- What is a Chain in a PO?
    
- What is a Complete Partial Order (CPO) and a $CPO_\perp$?
    
- What is a monotone function?
    
- What is a continuous function?
    
- **What is Kleene's Fixpoint Theorem?** (Statement and Proof sketch)
    
- **What is the Immediate Consequence Operator $\hat{R}$?**
    
- How can the set of theorems of a logical system be seen as a fixpoint?
    
- What is the domain $Z_\perp$ (integers with bottom)?
    
- How is the Cartesian Product of domains defined?
    
- How is the limit in a product domain calculated?
    
- What is the Function Space domain $[D \to E]$?
    
- How is the limit in a function space domain calculated?
    
- What is the Lifted Domain $D_\perp$?
    
- What is the `let` notation for lifted domains?
    

### Part 4: HOFL & Denotational Semantics

_Functional languages and consistency._

- What is the syntax of HOFL?
    
- What is the Type System of HOFL?
    
- What is a Principal Type?
    
- What are the rules for the Operational Semantics of HOFL?
    
- What is the difference between Lazy (Call-by-name) and Eager (Call-by-value) evaluation rules?
    
- What is a Canonical Form in HOFL?
    
- What is the Lambda-notation and Alpha-conversion?
    
- How is the Denotational Semantics of HOFL defined?
    
- What is the interpretation of types as domains?
    
- How is the `fix` operator defined denotationally?
    
- **What is the Substitution Lemma?**
    
- How to state the Compositionality Principle?
    
- What is the Consistency between Operational and Denotational semantics?
    
- Does Operational Convergence imply Denotational Convergence?
    
- What is the difference between Unlifted and Lifted semantics for HOFL?
    

### Part 5: Implementation of Concurrency

_Haskell, Erlang, Google Go._

- **Haskell:**
    
    - What is the syntax for list comprehension?
        
    - What is Pattern Matching and how does it work?
        
    - What is a Higher-Order function?
        
    - What is `fold` (foldr/foldl)?
        
- **Erlang:**
    
    - How are processes created (`spawn`)?
        
    - What is a PID?
        
    - What is the syntax for message passing (`!` or `send`)?
        
    - How does `receive` work (pattern matching on messages)?
        
    - What is the mailbox semantics?
        
- **Google Go:**
    
    - What is a Goroutine?
        
    - What is a Channel and how is it created?
        
    - Difference between buffered and unbuffered channels?
        
    - What is the `select` statement?
        
    - How does `select` handle multiple available channels?
        

### Part 6: CCS & Bisimulation

_Process algebras._

- What is the syntax of CCS?
    
- What is the LTS (Labelled Transition System) of CCS?
    
- What is the rule for parallel composition (`|`) and synchronization ($\tau$)?
    
- What is Strong Bisimulation? (Definition)
    
- What is the Bisimulation Game?
    
- **How to prove that two processes are Strongly Bisimilar?** (Costruire la relazione)
    
- Is Strong Bisimilarity a congruence?
    
- What is Weak Bisimulation?
    
- What is a Weak Transition ($\Rightarrow$)?
    
- Why is Weak Bisimilarity _not_ a congruence (in general)?
    
- What is Weak Observational Congruence?
    

### Part 7: Logics & Model Checking

_HML, LTL, CTL, Mu-Calculus._

- **HML:**
    
    - What is the syntax of Hennessy-Milner Logic?
        
    - What is the satisfaction relation $P \models \phi$?
        
    - What is the Diamond operator $\langle a \rangle \phi$ and Box operator $[a]\phi$?
        
    - Theorem: Relation between HML equivalence and Strong Bisimilarity.
        
- **Temporal Logics:**
    
    - What is the difference between Linear Time (LTL) and Branching Time (CTL)?
        
    - What is the syntax of LTL (Next, Until, Always, Eventually)?
        
    - When are two LTL formulas equivalent?
        
- **Mu-Calculus:**
    
    - What is the syntax of the Mu-Calculus?
        
    - What does the fixpoint operator $\mu X.\phi$ represent?
        
    - What is the difference between Least Fixpoint ($\mu$) and Greatest Fixpoint ($\nu$)?
        
    - How to express "deadlock freedom" or "mutual exclusion" in Mu-Calculus?
        

### Part 8: KAT - Kleene Algebra with Tests

_Final module._

- What is a Kleene Algebra (KA)? (Axioms for $+$, $\cdot$, $*$)
    
- What is a Boolean Algebra?
    
- **What is a Kleene Algebra with Tests (KAT)?** (Definition)
    
- How are tests embedded in the algebra?
    
- How can IMP programs be modeled using KAT?
    
    - Encoding of assignment (as atomic action).
        
    - Encoding of `if b then p else q` ($b \cdot p + \bar{b} \cdot q$).
        
    - Encoding of `while b do p` ($(b \cdot p)^* \cdot \bar{b}$).
        
- How to prove Hoare triples $\{P\} C \{Q\}$ using KAT?
    
- What is the advantage of KAT over standard operational semantics for verification?
    