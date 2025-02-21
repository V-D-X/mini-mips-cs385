# MIPS CPU Project

---

## Overview
Welcome to our MIPS CPU Project! This is a collaborative effort to design and implement a functional MIPS processor using Verilog. While this is an academic project, we're incorporating industry best practices to keep our design clean, efficient, and well-documented. 

GitHub will serve as our main platform for code, documentation, and collaboration.

---

## Table of Contents
1. [Project Goals](#project-goals)
2. [Repository Structure](#repository-structure)
3. [Tech Stack](#tech-stack)
4. [Git Best Practices](#git-best-practices)
   - [Branching Strategy](#branching-strategy)
   - [Commit Messages](#commit-messages)
   - [Conventional Commits](#conventional-commits)
   - [Pull Requests](#pull-requests)
   - [Code Style](#code-style)
5. [Testing Methodology](#testing-methodology)
6. [Debugging Strategies](#debugging-strategies)
7. [CI/CD Pipeline](#cicd-pipeline)
   - [How the Pipeline Works](#how-the-pipeline-works)
   - [Running the Pipeline Locally](#running-the-pipeline-locally)
   - [Troubleshooting](#troubleshooting)
8. [Getting Started](#getting-started)
9. [Contribution Guidelines](#contribution-guidelines)
10. [Resources](#resources)
11. [Contributors](#contributors)

---

## Project Goals
- Develop a functional MIPS CPU using Verilog.
- Implement key components such as instruction decoding, ALU operations, memory access, and control logic.
- Simulate and test thoroughly using testbenches.
- Follow structured coding and documentation practices inspired by industry standards.

---

## Repository Structure
```
MIPS-CPU-Project/
│── .github/             # GitHub-specific configurations 
│   ├── workflows/       # GitHub Actions workflows 
│   │   ├── ci.yml       # CI/CD pipeline configuration
│── docs/                # Project documentation, reports, and references
│   ├── logisim/         # Logisim circuit files
│   ├── references/      # Linked project resources and external references
│── src/                 # Source code for the Verilog implementation
│   ├── core/            # CPU core implementation
│   ├── alu/             # Arithmetic Logic Unit implementation
│   ├── control/         # Control unit implementation
│   ├── memory/          # Memory unit and cache
│   ├── pipeline/        # Pipeline registers (if implementing pipelining)
│── tests/               # Testbenches and verification scripts
│   ├── alu_tb.v         # ALU testbench
│   ├── memory_tb.v      # Memory unit testbench
│── scripts/             # Automation scripts (e.g., build, simulation)
│── results/             # Simulation and benchmarking results (waveforms, logs, reports)
│── .gitignore           # Files to be ignored by Git
│── README.md            # Project documentation
```

---

## Tech Stack
We’ll be using the following tools to develop, simulate, and debug our MIPS CPU:

- **Verilog Editor with IntelliSense:** [CoderPad Sandbox](https://app.coderpad.io/sandbox)
- **Digital Circuit Design:** [Logisim Evolution](https://github.com/logisim-evolution/logisim-evolution)
- **State Diagram Tool:** [FlatFire FSM Designer](https://flatfire.github.io/fsm/www/index.html)
- **Schematic & Simulation Tool:** [DigitalJS](http://digitaljs.tilk.eu/) – Allows direct Verilog input and generates schematics.
- **Alternative Verilog IDE (Under Testing):** [TerosHDL](https://terostechnology.github.io/terosHDLdoc/docs/intro) – Includes an integrated schematic viewer for debugging.
- **CI/CD Simulation:** [Icarus Verilog (iverilog)](http://iverilog.icarus.com/)
- **Waveform Debugging:** [GTKWave](http://gtkwave.sourceforge.net/)

---

## Git Best Practices
To keep our work organized and manageable, we'll stick to these guidelines:

### **Branching Strategy**
- **`main` branch:** Stable, working code only.
- **Feature branches (`feature/<name>`):** For new features (e.g., `feature/alu-design`).
- **Bugfix branches (`bugfix/<name>`):** For resolving issues (e.g., `bugfix/control-unit`).
- **Experimental branches (`exp/<name>`):** For extras that might not make it into the final version.

### **Commit Messages**
We follow **Conventional Commits** to maintain a structured Git history.

#### **Conventional Commits**
```
<type>(<optional scope>): <short description>

<optional body>

<optional footer>
```

### **Commit Types**
| Type      | Purpose |
|-----------|---------|
| **feat**  | Introduces a new feature |
| **fix**   | Fixes a bug |
| **chore** | Maintenance tasks (e.g., refactoring, CI updates) |
| **docs**  | Documentation changes |
| **style** | Formatting, whitespace, missing semicolons, etc. |
| **refactor** | Code restructuring without changing behavior |
| **test**  | Adding or updating tests |
| **perf**  | Performance improvements |
| **build** | Changes to build scripts, dependencies |
| **ci**    | Continuous integration changes |

#### **Example Commits**
```sh
feat(alu): add bitwise AND and OR operations
fix(memory): resolve segmentation fault in cache lookup
docs(readme): add CI/CD pipeline explanation
```

### **Pull Requests**
- Always create a PR before merging into `main`.
- PRs should be reviewed by at least one teammate.
- Include a description of what the PR does.
- Run tests before submitting a PR.

### **Code Style**
- Follow Verilog best practices and keep the code modular.
- Use meaningful names for variables and signals.
- Comment the code to explain complex logic where needed.

---

## Testing Methodology
Testing is critical to ensure our CPU functions as expected. We will use:

- **Unit Testing:** Test individual modules like ALU, Control, and Memory.
- **Integration Testing:** Check interactions between modules.
- **Simulation Tools:** Icarus Verilog.
- **Expected Test Coverage:** Ensure all MIPS instructions execute correctly.

Test results (waveforms, logs) should be stored in the `results/` directory.

---

## Debugging Strategies
Debugging Verilog can be challenging, so here are some effective strategies:

- **Enable Debugging Signals:** Add debug registers and print intermediate values.
- **Schematic Debugging:** Use [DigitalJS](http://digitaljs.tilk.eu/) or TerosHDL to visualize circuits.
- **Use Waveform Viewers:** Use GTKWave to analyze signal transitions.

---

## CI/CD Pipeline
Our CI/CD pipeline is designed to automate the testing and validation of the MIPS CPU implementation using GitHub Actions and Icarus Verilog.

### **How the Pipeline Works**
1. **Trigger Events:** The CI/CD pipeline is triggered on the following actions:
   - Push to `main` or `develop` branches
   - Opening a PR
   - Manual execution through GitHub Actions
2. **Pipeline Steps:**
   - **Build & Syntax Check:** Uses `iverilog` to compile Verilog code and detect syntax errors.
   - **Verify Test Coverage:** Ensures every Verilog module has a corresponding `_test.v` file. The pipeline will fail if a test is missing.
   - **Run Unit Tests:** Uses Icarus Verilog (`iverilog`) to compile and test the Verilog code.
   - **Waveform Analysis:** Stores simulation logs and waveform files for debugging if a failure occurs.
   - **Status Reporting:** Provides pass/fail results directly in GitHub PRs.

### **Running the Pipeline Locally**
If you want to test the pipeline before pushing changes, follow these steps:

1. **Ensure you have Icarus Verilog installed:**
   ```sh
   iverilog -V  # Verify installation
   ```
   If not installed, use:
   ```sh
   sudo apt install iverilog    # Linux (Debian-based)
   choco install iverilog       # Windows
   brew install icarus-verilog  # macOS
   ```

2. **Run tests manually:**
   ```sh
   iverilog -o testbench -I src test/*.v
   vvp testbench
   ```

3. **View waveforms (if needed):**
   ```sh
   gtkwave testbench.vcd
   ```

### Troubleshooting
- **Pipeline Failure on PRs:** Check the `Actions` tab on GitHub to see logs for errors.
- **Compilation Errors:** Run `iverilog` locally before pushing changes.
- **Simulation Issues:** Ensure testbenches cover all edge cases and signals are correctly set up.
- **Permission Errors:** If running scripts locally, ensure execution permission:
  ```sh
  chmod +x scripts/*.sh
  ```

---

## Getting Started
1. **Clone the repository:**
   ```sh
   git clone https://github.com/your-org/MIPS-CPU-Project.git
   ```
2. **Create a feature branch before working on a new task:**
   ```sh
   git checkout -b feature/<your-feature-name>
   ```
3. **Commit changes regularly:**
   ```sh
   git add <changed-files>
   git commit -m "[Component] Brief message"
   ```
4. **Push your branch and create a pull request:**
   ```sh
   git push origin feature/<your-feature-name>
   ```

---

## Contribution Guidelines
To keep our project organized and productive:

- **Open an Issue Before Major Changes:** Use GitHub Issues to discuss.
- **Follow Coding Standards:** Keep naming and formatting consistent.
- **Test Your Code Thoroughly:** Make sure it works before merging.
- **Review PRs:** Look for clarity, correctness, and efficiency.
- **Stay in Sync:** Use Slack or GitHub Discussions to coordinate.

### **PR Review Checklist**
- [ ] Code follows Verilog best practices  
- [ ] All new modules have a corresponding testbench  
- [ ] Simulation passes without errors  
- [ ] No redundant or unnecessary code changes  
- [ ] Clear and meaningful commit messages  

---

## Resources
- **Project Specification:** [`CS385 Semester Project`](docs/references/CS385_Semester_Project.htm)
- **Verilog Reference:** [Verilog Quick Reference](docs/references/VerilogQuickRef.pdf)
- **MIPS Reference:** [MIPS Instruction Set](docs/references/MIPS32%C2%AE%20Instruction%20Set%20Quick%20Reference.pdf)
- **Pipeline Diagrams:** [MIPS-16-Pipeline.pdf](docs/references/MIPS-16-Pipeline.pdf)
- **Git for Beginners:**
  - [GitHub Docs](https://docs.github.com/en/get-started)
  - [Pro Git Book](https://git-scm.com/book/en/v2)
  - [Learn Git Branching](https://learngitbranching.js.org/)
  - [Oh S***, Git!?!](https://ohshitgit.com/)

## Contributors

   <a href="https://github.com/V-D-X"><img src="https://github.com/V-D-X.png" width="50" height="50"></a>
   <a href="https://github.com/username2"><img src="https://github.com/username2.png" width="50" height="50"></a>
   <a href="https://github.com/username3"><img src="https://github.com/username3.png" width="50" height="50"></a>
