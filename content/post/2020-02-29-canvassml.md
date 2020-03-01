---
title: CanvassML
author: Stephen Holsenbeck
date: '2020-02-29'
heroHeading: "CanvassML"
heroSubHeading: "An application of machine learning to predict campaign support"
slug: canvassML
type: post
categories:
  - Machine Learning
  - Political Science
tags:
  - spatial
  - hyperparameter tuning
  - xgboost
  - ML
  - canvassing
  - politics
draft: yes
---

# Intro
All code for this project is hosted at [github.com/yogat3ch/canvassML](http://github.com/yogat3ch/canvassML)

This project has been absorbing most of my attention from January to February 2020 and is the result of about 75 hours of input. The topic, political science, is one that I find particularly engaging, and am easily moved to delve deeper into. I hope that you find the work equally as intriguing and educational! 

If you choose to read the [full analysis](../../../canvassML/), you'll find that the intro below is also found in the full analysis - so if you plan on reading it, go ahead to the main page. If you're just browsing and want to get an idea of what the work is about, please read on.

## Purpose and Description
This algorithm builds from previous work with spatial data and canvassing from 2018 [See 'My City in Time and Space'](https://rpubs.com/yogat3ch/ppua5302p2).  The project was inspired by the desire to assist the Andrew Yang Campaign with optimization of canvassing efforts. 
<br>

#### On delegate allocation
Massachusetts and New Hampshire use a threshold-based delegate allocation system. Fifteen percent of the vote of a congressional district (CD) must be acquired to win a portion of that CDs delegates, split proportionally between other threshold crossing candidates. State delegates are similar, but the threshold is applied at the state level, ie fifteen percent of the state votes must be acquired to receive a proportional amount of the state delegates. Thus it is imperative to focus on regions within congressional districts where support is likely to be densest. CanvassML is created to facilitate the targeting of canvassing campaigns. In this analysis we look at New Hampshire and Massachusetts, though the method could be extrapolated to any adjacent states
<br>

### Model description
The model uses two types of predictive variables: <strong>specific and demographic.</strong><br>
The <strong>specific predictors</strong> are comprised of aggregate numbers of supporters who have already affiliated themselves as supporters of the campaign. These are typically registered volunteers or others who've expressed their commitment to vote. A campaign might also use mailing list subscribers aggregated by zip code. 

The <strong>demographic predictors</strong> are comprised of census data. These data sources are used to characterize the demographic make-up of zip codes, and act as predictors for canvassing success per zip code.
Together, these data can be used as predictors in a predictive algorithm to be trained on areas where a reliable outcome variable is available, and tested on areas yet to be targeted for canvassing.

In this example, Massachusetts zip codes will be used as the target and data from New Hampshire zip codes will be used as the training set. Adjacent states within the same ["political region"](https://www.businessinsider.com/the-11-nations-of-the-united-states-2015-7) are likely to yield more accurate cross-state comparisons than those with large geographic separations.

### Outcome
New Hampshire 2020 primary election data are used as the response variable in the training data. This is possible because the primary has not yet taken place in Massachusetts, an adjacent state. If voter data is not available, aggregate success rates from existing canvass efforts for an area might also serve as an outcome variable in lieu of voting results. Polling results, if available aggregated by the required geographies, could also serve as the outcome variable. 

If your curiousity is piqued, please [read on](../../../canvassML/index.html#outcome)