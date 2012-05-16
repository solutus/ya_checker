##DESCRIPTION
  ya_checker - retrieves search results for keyword from xml.yandex.ru and returns url from particular position.

##SYNOPSIS
  ya_checker [KEYWORD...] [OPTIONS]

  -h, --help:
     show help

  --number x, -n x:
     url position number in response

  --url "url", -u "url":
     xml.yandex url in quotes

  KEYWORD - words should to be found in yandex search

## EXAMPLE
  ya_checker ruby vim -n 2 --url "http://xmlsearch.yandex.ru/xmlsearch?user=USER&key=KEY"
