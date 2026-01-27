# Shell Scripting Basics: Exercises

Complete these exercises to master bash scripting.

## Exercise 1: Create Simple Script

**Tasks:**
1. Create script with shebang
2. Add echo statement
3. Make executable
4. Run successfully
5. View script contents

**Hint:** Use `nano`, `chmod +x`, `./script.sh`.

---

## Exercise 2: Use Variables

**Tasks:**
1. Declare variables
2. Use command substitution
3. Display with echo
4. Combine variables
5. Export variable

**Hint:** `VAR="value"`, `$(date)`, `echo "$VAR"`.

---

## Exercise 3: Accept Command Arguments

**Tasks:**
1. Create script accepting args
2. Use $1, $2, $3
3. Use $@ for all args
4. Count arguments with $#
5. Display argument info

**Hint:** `./script.sh arg1 arg2 arg3`.

---

## Exercise 4: Conditional Logic

**Tasks:**
1. Test file existence
2. Test directory existence
3. Compare numbers
4. Compare strings
5. Use multiple conditions with &&/||

**Hint:** `[ -f file ]`, `[ -d dir ]`, `[ $a -eq $b ]`.

---

## Exercise 5: Loop Through Items

**Tasks:**
1. Use for loop with list
2. Loop through command output
3. Use while loop with counter
4. Break out of loop
5. Continue to next iteration

**Hint:** `for i in item1 item2`, `while [ $i -lt 10 ]`.

---

## Exercise 6: Create Functions

**Tasks:**
1. Define function
2. Call function
3. Pass arguments to function
4. Return values from function
5. Reuse functions in script

**Hint:** `function_name() { code }`, `$1` in function.

---

## Exercise 7: Error Handling

**Tasks:**
1. Check exit status
2. Use set -e to exit on error
3. Trap errors with trap command
4. Validate user input
5. Provide helpful error messages

**Hint:** `$?`, `set -e`, `trap 'cleanup' EXIT`.

---

## Exercise 8: File Operations

**Tasks:**
1. Read file line by line
2. Check file permissions
3. Write to file
4. Append to file
5. Process multiple files

**Hint:** `while IFS= read -r line`, `ls -l`, `>>`.

---

## Exercise 9: String Manipulation

**Tasks:**
1. Extract substring
2. Replace text in string
3. Convert case
4. Count characters
5. Validate patterns with regex

**Hint:** `${var:0:5}`, `${var//old/new}`, `=~`.

---

## Exercise 10: Build Practical Script

Create complete production-ready script.

**Tasks:**
1. Accept multiple arguments
2. Include functions
3. Add error handling
4. Validate inputs
5. Generate useful output

**Hint:** Combine all previous exercises.
