# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

import os
import sys
sys.path.insert(0, os.path.abspath('../'))  # Aggiungi il percorso della tua repo

project = 'AutoDock-AI'
copyright = '2025, Daniel Rossi'
author = 'Daniel Rossi'
release = '1.0.0'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = ['sphinx.ext.autodoc',
              'sphinx.ext.intersphinx',
              'sphinx.ext.autosummary',
              'sphinx.ext.napoleon',
              'sphinx.ext.viewcode',
              'sphinx.ext.viewcode',
              'sphinx_tabs.tabs',
              'sphinx-prompt',
              'sphinx_toolbox',
              'sphinx.ext.autosectionlabel']

github_username = 'danielrossi1'
github_repository = 'AutoDock'

lanugage = 'en'
autosummary_generate = True

templates_path = ['_templates']
exclude_patterns = []



# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'alabaster'
html_static_path = ['_static']
html_theme = 'furo'
html_favicon = '_static/AutoDockAI-logo.jpeg'
