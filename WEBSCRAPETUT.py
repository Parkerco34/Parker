from requests import get
from bs4 import BeautifulSoup
import pandas as pd
# We want to analyze the distributions of IMDB and Metacritic movie ratings to see if we find anything interesting:
# There are 50 movies shown per page, so there should be a div container for each.
# The 'html.parser' argument indicates that we want to do the parsing using Python’s built-in HTML parser.
url = 'https://www.imdb.com/search/title/?release_date=2017&sort=num_votes,desc&page=2&ref_=adv_nxt'
response = get(url)
responseObj = response.text
html_soup = BeautifulSoup(response.text,'html.parser')
# html_soup = BeautifulSoup(response.text,'lxml')***
# Before extracting the 50 div containers, figure out what distinguishes them from other div elements on that page...
#  find_all() method to extract all the div containers that have a class attribute of lister-item mode-advanced:
movie_containers = html_soup.find_all('div',class_ = 'lister-item mode-advanced')

# The name of the movie:
first_movie = list(movie_containers)[0]
# first_movie.div
firstName = first_movie.h3.a.text

# The year of the movie’s release:
# Dot notation will only access the first span element***
# find() - returns the first match
first_year = first_movie.h3.find('span',class_='lister-item-year text-muted unbold')
first_year.text

# The IMDB rating:
first_imdb = float(first_movie.strong.text)

# The Metascore:
first_meta = first_movie.find('span',class_='metascore favorable')
first_mscore = int(first_meta.text)

# The number of votes:
firstVotes = first_movie.find('span',attrs={'name':'nv'})
# Using BeautifulSoup we can access elements by any attribute.
firstVotes = int(firstVotes['data-value'])

# The script for a single page:
# We need to add a condition to skip movies without a Metascore.
twentythree_metaScore = movie_containers[22].find('div',class_='ratings-metascore')
#=========================================================================================================================
names = []
years = []
imdbRatings = []
metaScores = []
votes = []

for container in movie_containers:
    if container.find('div',class_='ratings-metascore') is not None:
        name = container.h3.a.text
        names.append(name)
        
        year = container.h3.find('span',class_='lister-item-year text-muted unbold')
        years.append(year)
        
        imdbRating = float(container.strong.text)
        imdbRatings.append(imdbRating)
        metaScore = container.find('span',class_='metascore').text
        metaScores.append(int(metaScore))
        
        vote = container.find('span',attrs={'name':'nv'})['data-value']
        votes.append(int(vote))
        
test_df = pd.DataFrame({'MOVIE':names,'YEAR':years,'IMDB RATING':imdbRatings,'METASCORE':metaScores,'VOTES':votes})
#=========================================================================================================================
#==============================================The script for multiple pages==============================================



        


