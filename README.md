# STAT 8310 - Bayesian Data Analysis

November 1, 2026

**Chi-Kuang Yeh**\
*Georgia State University*

## Description

This is the repo for the course STAT 8310 - Bayesian Data Analysis
offered at Georgia State University in Spring 2027.

Course website: <https://chikuang.github.io/teaching/2027S_stat8310/>

The `2027S` branch starts from the previous offering. Dates and course
arrangements are tentative.

## Build and publish

Run `quarto render --to pdf`, then `quarto render --to html --no-clean`
from this directory to retain both formats in `_book/`. The project uses
frozen results for unchanged chapters. Publish `_book/` to
`teaching/2027S_stat8310/` in `chikuang/chikuang.github.io`.

## PDF style

The PDF follows the STAT 8670 / STAT 8561 course-note layout: a
dedicated cover, section headings, running course/section headers, and
linked course footers. `pdf-page-style.tex` uses darker Cosmo blues
(`#1D5FA6`, `#163E68`, `#3B5F85`) for legibility on white.
`pdf-environments.tex` and the PDF-only Lua filters provide coloured,
breakable theorem/example boxes and wrapped code listings. HTML keeps
the existing Cosmo theme.
