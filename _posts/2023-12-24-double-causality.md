---
layout: post
title: "Does Causality Only Stay in the Local Environment"
date: 2023-12-24
---

When we have two variables of interest, $`X`$ and $`Y`$, and want to do some preliminary analysis, 
we normally use the correlation between the two variables. i.e. $Cov(X, Y)$. 

Now, people care about the causality between $X$ and $Y$. Different methods have been developed to study (1) whether $X \rightarrow Y$ or $Y \rightarrow X$ and (2) what is the correct treatment effect. 

However, does this mean that only one causal relationship can exist? For instance, in an economy studying the price and quantity, it seems to be more of a general equilibrium framework that the price moves quantity and quantity moves price as well. Fixing the demand curve and standing on the viewpoint of a competitive producer, an exogeneous shock to the price (quantity) will definitely change the quantity (price). Therefore, it seems that $X \Longleftrightarrow Y$ and maybe we have this "double causality". 

In addition, this may be the reason of having structual estimation in place. 
