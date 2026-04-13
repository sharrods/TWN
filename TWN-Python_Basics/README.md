# TWN-Python_Basics
# Module 13 — Python Basics

## What I Built
[fill in after completing module]

---

## Lessons 1-6 — Core Concepts (Lecture)

### Data Types
- string = text `"hello"`
- int = whole number `42`
- float = decimal `3.14`
- bool = True or False

### Variables
```python
name = "Sdot"
age = 35
is_devops = True
```

### Operators
```python
# Arithmetic
x + y    # addition
x - y    # subtraction
x * y    # multiplication
x / y    # division
x % y    # modulus (remainder)
x ** y   # exponentiation
x // y   # floor division

# Comparison
x == y   # equal
x != y   # not equal
x > y    # greater than
x < y    # less than
x >= y   # greater than or equal
x <= y   # less than or equal
```

---

## Lesson 7 — Functions

```python
def days_to_units(num_of_days):
    conditional_check = num_of_days > 0
    print(type(conditional_check))
```

- def = define a function
- functions avoid repeating code
- parameters = inputs to the function
- return = send a value back

---

## Lesson 8 & 9 — Accepting User Input & if/else conditionals

```python
calculation_to_hours = 24
name_of_unit = "hours"

def days_to_units(num_of_days):
    conditional_check = num_of_days > 0
    print(type(conditional_check))

    if num_of_days > 0:
        return f"{num_of_days} days are {num_of_days * calculation_to_hours} {name_of_unit}"
    else:
        return "You entered a negative value, so no conversion for you!!"


user_input = input("Hey user, enter a number of days and I will convert it to hours! \n")
user_input_number = int(user_input)


my_var = days_to_units(user_input_number )
print(my_var)

```

---
## Add 
- if/else
- 0 entered
- cast to integer 
    - int(some text)
- validate
    - if user_input.isdigit():
          user_input_number = int(user_input)
          my_var = days_to_units(user_input_number)
          print(my_var)
     else:
         print("Your input is not a number. Don't ruin my program!!") 

- Trying to filter out all bad user input w/isdigit()
- Make it a function now as part of DRY
```python
def validate_and_execute():
    if user_input.isdigit():
        user_input_number = int(user_input)
        my_var = days_to_units(user_input_number)
        print(my_var)
    else:
        print("Your input is not a number. Don't ruin my program!!")

user_input = input("Hey user, enter a number of days and I will convert it to hours! \n")
validate_and_execute()
```


### Combine Validation inside the function

```python
### Combine Validation
def validate_and_execute():
    if user_input.isdigit():
        user_input_number = int(user_input)
        if user_input_number > 0:
            my_var = days_to_units(user_input_number)
            print(my_var)
        elif user_input_number == 0:
            print("You entered a 0, please enter a valid positive number")
    else:
        print("Your input is not a number. Don't ruin my program!!")

user_input = input("Hey user, enter a number of days and I will convert it to hours! \n")
validate_and_execute() 
```


### Try / Except with while loop

- rm isdigit and replac w/ try block to catch all errors
- handle Value Errors changed to handle all errors (try catch) method
- assign empty string
- Use while loop to break on exit 

```python
while user_input != "exit":
    user_input = input("Hey user, enter a number of days and I will convert to a hours!\n")
validate_and_execute()
```



---

## Lesson 10 — Error Handling

```python
try:
    result = 10 / 0
except ZeroDivisionError:
    print("can't divide by zero")
except Exception as e:
    print(f"something went wrong: {e}")
finally:
    print("always runs")
```

- try = attempt this code
- except = handle the error
- finally = always runs regardless

---

## Lesson 11 — While Loops

```python
count = 0
while count < 5:
    print(count)
    count += 1
```

- runs while condition is True
- always make sure condition eventually becomes False or it loops forever

---

## Lesson 12 — Lists and For Loops

```python
tools = ["terraform", "ansible", "docker"]

for tool in tools:
    print(tool)

# useful list methods
tools.append("kubernetes")   # add to end
tools.remove("docker")       # remove item
len(tools)                   # length
tools[0]                     # access by index
```

---

## Lesson 13 — Comments

```python
# single line comment

"""
multi line
comment
"""
```

---

## Lesson 14 — Sets

```python
my_set = {1, 2, 3, 3, 3}
print(my_set)   # {1, 2, 3} — duplicates removed

# sets are unordered and unique values only
# useful for deduplication
```

---

## Lesson 15 — Built-In Functions

```python
len("hello")        # 5
type(42)            # int
str(42)             # "42"
int("42")           # 42
range(5)            # 0,1,2,3,4
print()
input()
```

---

## Lesson 16 — Dictionary

```python
server = {
    "host": "10.0.0.1",
    "port": 22,
    "user": "ec2-user"
}

server["host"]           # access value
server["region"] = "us-east-1"  # add key
server.keys()            # all keys
server.values()          # all values
server.items()           # key-value pairs
```

---

## Lesson 17 — Modules

### What I Built
- split the day converter app into two files
- `helper.py` = reusable functions and message
- `main.py` = imports from helper and runs the loop

### main.py
```python
from helper import validate_and_execute, user_input_message

user_input = ""
while user_input != "exit":
    user_input = input(user_input_message)
    days_and_unit = user_input.split(":")
    days_and_unit_dictionary = {"days": days_and_unit[0], "unit": days_and_unit[1]}
    validate_and_execute(days_and_unit_dictionary)
```

### helper.py
```python
def days_to_units(num_of_days, conversion_unit):
    if conversion_unit == "hours":
        return f"{num_of_days} days are {num_of_days * 24} hours"
    elif conversion_unit == "minutes":
        return f"{num_of_days} days are {num_of_days * 24 * 60} minutes"
    else:
        return "unsupported unit"

def validate_and_execute(days_and_unit_dictionary):
    try:
        user_input_number = int(days_and_unit_dictionary["days"])
        if user_input_number > 0:
            calculated_value = days_to_units(user_input_number, days_and_unit_dictionary["unit"])
            print(calculated_value)
        elif user_input_number == 0:
            print("you entered a 0, please enter a valid positive number")
        else:
            print("you entered a negative number, no conversion for you!")
    except ValueError:
        print("your input is not a valid number. Don't ruin my program")

user_input_message = "Hey user, enter number of days and conversion unit!\n"

```python
import os
import sys

# import specific function
from os import path

# your own module
import my_module
my_module.my_function()
```

- module = a .py file with reusable code
- import = bring in external code
- Python standard library has modules for almost everything

---


## Lesson 18 — Project: Countdown App

### What I Built
- day converter app that takes user input and converts days to hours or minutes
- validates input — handles negatives, zero, and non-numeric values
- uses functions, conditionals, error handling, and dictionaries together

### What Each Part Does
- `days_to_units()` = does the math and returns a formatted string
- `validate_and_execute()` = validates input before passing to converter
- `try/except ValueError` = catches non-numeric input like "abc"
- dictionary input = groups days and unit together as one argument
- f-strings = formats the output message with calculated values




### Program
```python
def days_to_units(num_of_days, conversion_unit):
    if conversion_unit == "hours":
        return f"{num_of_days} days are {num_of_days * 24} hours"
    elif conversion_unit == "minutes":
        return f"{num_of_days} days are {num_of_days * 24 * 60} minutes"
    else:
        return "unsupported unit"


def validate_and_execute(days_and_unit_dictionary):
    try:
        user_input_number = int(days_and_unit_dictionary["days"])
        if user_input_number > 0:
            calculated_value = days_to_units(user_input_number, days_and_unit_dictionary["unit"])
            print(calculated_value)
        elif user_input_number == 0:
            print("you entered a 0, please enter a valid positive number")
        else:
            print("you entered a negative number, no conversion for you!")
    except ValueError:
        print("your input is not a valid number. Don't ruin my program")

```



user_input = input("enter your goal with a deadline separated by a colon\n")
input_list = user_input.split(":")

goal = input_list[0]
deadline = input_list[1]

deadline_date = datetime.datetime.strptime(deadline, "%d.%m.%Y")
today_date = datetime.datetime.today()
time_till = deadline_date - today_date
# Calculate how many days from now till deadline

hours_till = int(time_till.total_seconds() / 60 / 60)
print(f"Dear user! Time remaining for your goal: {goal} is {time_till.total_seconds() / 60 / 60} days")
```

---

## Lesson 19 — Packages, PyPI and pip

```bash
pip install requests
pip install boto3        # AWS SDK for Python
pip list                 # show installed packages
pip freeze               # show with versions
pip freeze > requirements.txt
pip install -r requirements.txt
```

- PyPI = Python Package Index — like npm for Node
- pip = package manager for Python
- requirements.txt = lock file for dependencies

---

## Lesson 20 — Project: Automation with Python (Spreadsheet)
[fill in after completing]

---

## Lesson 21 — OOP: Classes and Objects

---

## Lesson 21 — OOP: Classes and Objects

### What I Built
- User class with attributes and methods
- Post class that references a User
- split into separate files and imported into main

### user.py
```python
class User:
    def __init__(self, user_email, name, password, current_job_title):
        self.email = user_email
        self.name = name
        self.password = password
        self.current_job_title = current_job_title

    def change_password(self, new_password):
        self.password = new_password

    def change_job_title(self, new_job_title):
        self.current_job_title = new_job_title

    def get_user_info(self):
        print(f"User {self.name} currently works as a {self.current_job_title}. You can contact them at {self.email}")
```

### post.py
```python
class Post:
    def __init__(self, message, author):
        self.message = message
        self.author = author

    def get_post_info(self):
        print(f"Post: {self.message} written by {self.author}")
```

### main.py
```python
from user import User
from post import Post

app_user_one = User("nn@nn.com", "Nana Janashia", "pwd1", "DevOps Engineer")
app_user_one.get_user_info()

app_user_two = User("aa@aa.com", "James Bond", "supersecret", "Agent")
app_user_two.get_user_info()

new_post = Post("on a secret mission today", app_user_two.name)
new_post.get_post_info()
```
---

## Lesson 22 — Project: API Request to GitLab

### What I Built
- Python script that hits the GitLab API
- prints all project names and URLs for a user

### Program
```python
import requests

response = requests.get("https://gitlab.com/api/v4/users/techworld-with-nana/projects")
my_projects = response.json()

for project in my_projects:
    print(f"Project Name: {project['name']}\nProject Url: {project['http_url_to_repo']}\n")
```

### What Each Part Does
- `requests` = third party library for HTTP requests (install with pip)
- `response.json()` = parses JSON response into Python list of dictionaries
- for loop iterates over each project object
- `project['name']` = accesses dictionary key from the API response

### Install requests
```bash
pip install requests
```
---

## Key Concepts
- Python is interpreted — runs line by line
- indentation matters — use 4 spaces not tabs
- everything is an object in Python
- f-strings for string formatting: `f"Hello {name}"`
- list = ordered, mutable, allows duplicates
- set = unordered, unique values only
- dict = key-value pairs
- modules = reusable code in .py files
- packages = collections of modules
- functions with parameters and return values
- conditionals with if/elif/else
- try/except error handling
- dictionary data type
- f-string formatting
- int() conversion from string input
- split large programs into separate .py files
- `from module import function` imports specific items
- `import module` imports the whole file
- keeps main.py clean — only logic that runs the app
- helper.py only contains reusable functions
- class = blueprint for creating objects
- `__init__` = constructor, runs when object is created
- `self` = reference to the current instance
- attributes = data stored on the object (self.name, self.email)
- methods = functions that belong to the class
- instance = a specific object created from the class
  `app_user_one` and `app_user_two` are two instances of User

---

## Issues and Resolutions
