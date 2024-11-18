+++
{{ $nameWithoutDate := slicestr .Name 6 }}author = "Ricardo Cino"
title = "{{ replace $nameWithoutDate "-" " " | title }}"
slug = "{{ $nameWithoutDate }}"
date = {{ .Date }}
tags = []
images = []
draft = true
+++

Introduction

<!--more-->

## Title
