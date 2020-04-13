Part 11: Building executable file and distributing via Steam
============================================================

When distributing your game to other people (via Steam or other platform), you cannot give them a bunch of .py files.
A distributable package must include a "native" executable file (exe on Windows or binary executable on Linux).

There are few tools that build native executables from python scripts. We'll use pyinstaller.

First, you need to install pyinstaller.

.. code-block:: none

    pip install pyinstaller

Then, navigate to the foder with main.py and run the following command:

.. code-block:: none

    pyinstaller --onefile --windowed --hidden-import numbers --icon assets\gfx\icon.ico main.py

If the command ran successfully, pyinstaller should create the following folders/files in your project folder:

* dist folder - this is where you'll find the game executable ("main.exe" on Windows or "main" binary executable on Linux)
* build folder - just pyinstaller's build stuff
* main.spec file

To complete the work, copy the assets folder to the dist folder and try running the executable file.

Did it work? Congratulations, you have completed the tutorial and wrote a fully functional game! Don't hesitate to show
it to your friends and family :)

Few remarks on switches we used in the :code:`pyinstaller` command:

* :code:`icon` - adds an icon to the exe file, to replace the ugly default icon
* :code:`hidden-import numbers` - tells pyinstaller to import an additional dependency used by kaa which is not exposed directly, thus invisible to pyinstaller
* :code:`onefile` - tells pyinstaller to add all dependencies to form just one executable file. Without this flag, dist folder will have a bunch of other lib files which you'll need to distribute with the game.
* :code:`windowed` - tells pyinstaller that it's not a python script but a windowed app

Check out the `pyinstaller documentation <https://pyinstaller.readthedocs.io/en/stable/>`_ for much better description of all available options and their meaning.

Troubleshooting
~~~~~~~~~~~~~~~

* The executable was built successfully but fails to run, showing just "failed to execute script 'main'"? Delete the dist and build folders and run the pyinstaller command again, **without :code:`--onefile` and :code:`--windowed` options**. Then run the game **from the command line** (cmd.exe on Windows or terminal on Linux). It will print out python stack trace which hopefully will tell you more about the problem.
* if :code:`pyinstaller` command did not complete successfully, check out the error message and look at the logs (inside "build" folder which will also.


Distributing kaa games on steam
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once you have distributable package (assets + binary executable) you can distribute it via Steam. Whe you configure your game for distribution
in the Steamworks panel, be sure to go to Installation->Redistributable Packages and select "Visual C++ Redist 2017" and "DirectX June 2010"


Games made with kaa
~~~~~~~~~~~~~~~~~~~

"Git Gud or Get Rekt!" - `retro space shooter, available for free on Steam <https://store.steampowered.com/app/1117810/Git_Gud_or_Get_Rekt>`_

Did you make your own game with the kaa engine? Let us know! We'll be more than happy to include it on the list.

