https://codeling.dev/blog/python-uv/#running-your-scripts-with-uv

Manage Python Projects With uv
Written by Brendon
11 June 2025
From managing dependencies to running scripts, uv is changing the way we handle Python projects. This guide breaks down how to use uv for lightning-fast, reliable Python development.

Spaceship flying through galaxy
Introduction
Installing uv
Verify uv Installation
Dependency Management with uv
Adding Dependencies
Upgrading Dependencies
Removing Dependencies
Adding Dev Dependencies
Running Scripts with uv
Running Your Scripts with uv
Project Files and Locking
pyproject.toml — The Project Blueprint
uv.lock — Pin Everything, Predict Everything
uv tree — Peek Into the Dependency Forest
Dependency Caching
Fast Installs, Thanks to Caching
Cache Hygiene
Managing Different Python Versions
Global Python Versions
Project Specific Python Versions
Cross-Version Compatibility Without Guesswork
Compatibility Check, Built In
Tools vs Installing — Meet uvx
What Is uvx?
When to Use uvx
uvx Under the Hood
Not for Project Dependencies
Wrapping Up
Introduction #
Python packaging has come a long way since the dark days of easy_install, but let’s be honest — it’s still a bit of a mess. You've got pip for installing, venv for isolation, requirements.txt for pinning, pip-tools for syncing, poetry if you're feeling modern, and a whole lot of “wait, why is this broken now?” in between. Every tool solves part of the puzzle, and yet somehow the whole still feels like a Jenga tower waiting for a sneeze.

Enter uv: a blazing-fast Python package and project manager written in Rust by the folks at Astral (yes, the same people who built the Ruff linter). Think of uv as the multi-tool that’s out to replace your cluttered toolbox.

It installs dependencies. It locks them. It syncs them. It runs scripts. It caches aggressively.

In this post, we're going to break down everything uv can do — from managing dependencies and lockfiles, to caching, script running, Python version pinning, and its nifty sibling uvx. Whether you're a solo dev trying to wrangle your personal projects, or a team lead desperate for reproducible builds that don’t feel like a gamble, uv might just be your new favorite tool.

Let’s dive in — no dependency hell required.

By the way, here's the video version of this article. Perfect if you want a short, high level overview before diving into this more in depth article.


Installing uv #
Before you unleash the speed and ease of uv, you’ll need to install it. Fortunately, the team at Astral understands that nobody wants to fight their package manager just to install a new package manager.

Here’s the quickest way to get started:

MacOS and Linux

curl -LsSf https://astral.sh/uv/install.sh | sh
Windows

powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
That command downloads a prebuilt binary for your platform which is ready to go. No virtual environment setup. No pip spaghetti.

Prefer something more package-manager-official? You’ve got options:

Homebrew (macOS/Linux):

brew install astral-sh/uv/uv
pipx:

pipx install uv
Verify uv Installation #
Once installed, verify it’s working:

uv --version
You should see something like uv x.y.z depending on the version.

Dependency Management with uv #
If you’ve used pip, you know the dance: install a package, maybe pin a version, maybe forget to update your requirements.txt, maybe break your environment six months later. uv simplifies this by combining dependency management and locking into one fast, streamlined experience.

Here’s how it works.

Adding Dependencies #
Need a package? Just ask:

uv add requests
This does three things in one shot:

Updates your pyproject.toml with the new dependency
Resolves a full dependency graph
Generates or updates a uv.lock file to lock it all down
No manual edits, no extra sync steps, no “did I forget to regenerate my lockfile?” surprises.

Want to specify a version?

uv add requests==2.31.0
It’s as explicit as you want it to be.

Upgrading Dependencies #
Upgrading dependencies with uv is done with the --upgrade parameter:

uv add requests --upgrade
This safely upgrades the package and rewrites the lockfile to reflect the new version.

Removing Dependencies #
Uninstalling dependencies is just as easy as adding them:

uv remove requests
No orphaned packages. No lockfile drift.

Adding Dev Dependencies #
Want to add tools like linters, formatters, or test runners without polluting your production environment?

uv add --dev black pytest
uv tucks them away under [tool.uv] dev-dependencies in your pyproject.toml, keeping your runtime environment clean and your tooling close at hand.

Running Scripts with uv #
uv run makes sure your scripts run in the context of your project’s environment — using exactly the versions you’ve declared and locked.

Think of it like npm run or poetry run, but faster and with less ceremony.

Say you’ve added black and pytest as dev dependencies. You can run them like this:

uv run black .
uv run pytest
No need to activate a virtual environment. No need to remember which version of black you installed. uv reads from your lockfile and runs the exact version you’ve specified.

Running Your Scripts with uv #
uv run executes commands in your project's environment — using only the dependencies declared in your lockfile.

Want to run my_script.py?

uv run python my_script.py
Working on a DJango project? Start the dev server like so:

uv run manage.py runserver
It's exactly like using a virtual environment — minus the manual setup, activation, deactivation, and that one time you accidentally ran pip install globally (we’ve all been there).

Project Files and Locking #
Now that you're installing and running packages with ease, let’s talk about how uv keeps your project organized and reproducible. This is where the real magic happens — not with vague “it probably works” environments, but with deterministic, lockfile-powered precision.

pyproject.toml — The Project Blueprint #
pyproject.toml is the central configuration file for modern Python projects — and uv uses it as the source of truth for your dependencies.

When you run something like:

uv add requests
uv adds that dependency to the pyproject.toml under the appropriate section (either [project.dependencies] or [tool.uv.dev-dependencies], depending on whether you use --dev). It doesn't invent a new standard — it builds on the one the Python ecosystem is already rallying around.

The result: your project metadata and dependencies are all in one place. Clean. Editable. Version-controlled. As it should be.

uv.lock — Pin Everything, Predict Everything #
Where pyproject.toml defines what you want, uv.lock defines exactly what you're getting — down to the last transitive dependency.

This lockfile is automatically created or updated whenever you run commands like uv add, uv remove, or uv sync. It ensures that every machine (or CI pipeline) installs the same versions, every time.

No more "but it worked yesterday." No more "why does the same install produce different results?" Just a lockfile you can trust.

Need to update everything? Run:

uv sync --upgrade
Want to just make sure your environment matches the lockfile?

uv sync
uv tree — Peek Into the Dependency Forest #
Curious about what's actually installed? uv gives you visibility without the clutter:

uv tree
This prints a neatly formatted dependency tree based on your lockfile. No more digging through pip freeze outputs wondering who brought in urllib3 five times. You’ll see exactly what’s being pulled in, and why.

You can even use --all to include dev dependencies or --top-level-only for a more minimal view.

With pyproject.toml giving structure, uv.lock providing reproducibility, and uv tree offering transparency, uv helps you treat your project like a first-class citizen — not a pile of versioned guesses.

Dependency Caching #
Most Python developers have a common ritual: install dependencies, wait a bit, install them again somewhere else, wait again, and then—just for fun—wait a third time in CI.

uv breaks the loop.

Fast Installs, Thanks to Caching #
One of uv’s standout features is its aggressive caching strategy. When you install a package, uv:

Resolves dependencies
Downloads and builds wheels (or uses prebuilt ones)
Caches the results to disk
The next time you install the same thing? It's instant.

Where does it stash these caches? By default, in a system-wide location (~/.cache/uv on Unix-like systems). This means:

All projects on your machine can reuse them
CI pipelines can benefit from caching if you persist the right folders
Offline installs just work, assuming the packages are already cached
No more redundant downloads. No more rebuilding wheels. uv respects your time — and your bandwidth.

Cache Hygiene #
Worried about your cache becoming a landfill of old versions? uv handles it gracefully.

It only keeps what's actually useful.
You can manually clear it if you’re the "clean desk" type:
uv cache clean
Managing Different Python Versions #
Dependencies are only half the story. The other half? The actual Python interpreter running your code.

With uv, you're able to manage globally available Python versions as well as the specific version you need in your project.

Global Python Versions #
To see which versions of Python are available as well as which of those are installed on your machine, you can run:

uv python list
Installing a new version of Python globally on your machine is as simple as:

uv python install 3.12
Simply specify which version you want. Quick and easy.

Project Specific Python Versions #
By creating a .python-version file in your project, you can specify which version of Python to use. This version will be specific to your project and can be different from your global machine version.

This is a simple text file that contains the version of Python your project expects:

3.13
When you run uv, it checks this file to figure out which Python version to use within your project.

Cross-Version Compatibility Without Guesswork #
Here’s where it gets interesting: uv doesn’t just use .python-version as a suggestion — it actually resolves dependencies based on the specified Python version.

That means:

If a dependency doesn't support Python 3.11, you’ll know at install time, not runtime.
Lockfiles generated by uv are Python-version-specific, preventing unpleasant surprises across machines or CI environments.
Want to change the Python version for your project? Just update .python-version, and re-sync:

uv sync
uv will re-resolve everything to match the new interpreter version.

Compatibility Check, Built In #
No more crossing your fingers after switching to a new Python version. uv ensures that your lockfile reflects the actual supported dependencies for that specific interpreter version. And that includes platform-specific wheels too.

Whether you’re building on macOS, deploying to Linux, or testing on Windows, uv keeps things sane and consistent.

In short: .python-version plus uv means your environment isn’t just “close enough.” It’s exact, predictable, and rock-solid — even across teams and systems.

Tools vs Installing — Meet uvx #
Sometimes, you just want to run a tool and move on with your life. You don’t want to add it to your project. You don’t want to pin it. You definitely don’t want to argue with pip.

Enter uvx.

What Is uvx? #
uvx is your go-to for running command-line tools without installing them into your project. Think of it like npx for Python: ephemeral, efficient, and always pulling the latest version (unless told otherwise).

Want to run black just once, without polluting your environment?

uvx black .
That’s it. No project changes, no lockfile updates. Just a clean run.

When to Use uvx #
Use uvx when:

You want to test a tool before committing to it
You’re scripting something quick and don’t want to bloat your pyproject.toml
You need the latest version of a tool without locking it
You’re running one-off commands in CI or automation scripts
It’s perfect for utilities like:

black
httpie
pytest
mypy
Or even your own CLIs published to PyPI.

uvx Under the Hood #
Behind the scenes, uvx downloads and caches the tool (fast, of course), then runs it in a temporary environment.

No installs. No cleanup. No regrets.

Not for Project Dependencies #
Important note: tools run with uvx aren’t added to your lockfile, aren’t managed by your project, and won’t be available in uv run.

So if you want something to be part of your reproducible, locked setup? Use uv add instead.

With uvx, the tooling barrier drops to near zero. Try, test, explore — without clutter.

But when you’re ready to commit, bring those tools into your workflow properly using the dependency commands we covered earlier.

Wrapping Up #
Python packaging has been... a journey. We've lived through pip, pipenv, poetry, virtual environments, lockfiles, dependency hell, and mysterious import errors that only happen on Wednesdays.

Enter uv, where you get:

Instant installs thanks to caching
Bulletproof lockfiles that honor Python version constraints
A unified workflow for adding, upgrading, and removing dependencies
Clean and minimal scripting with uv run
Lightweight one-off tooling via uvx
Zero configuration virtual environments — without even needing to say the word "venv"
And it’s all wrapped in a single tool that Just Works™ — whether you’re a solo developer or managing a production pipeline.
