from requests import get
from bs4 import BeautifulSoup as BS
import pandas as pd
from time import sleep
import time
from random import randint
from IPython.core import display
import warnings as war
#---------------------------------# Piecing everything together----------------
'''
url = 'https://www.imdb.com/search/title/?release_date=2017&sort=num_votes,desc&page=2&ref_=adv_nxt'
response = get(url) # content from web page stored here
responseObj = response.text # describes the overall structure of that web page
html_soup = BS(responseObj,'html.parser')
# find_all() method looks through a tag’s descendants and retrieves all descendants that match your filters.
# find_all(name, attrs, recursive, string, limit, **kwargs)
movie_containers = html_soup.find_all('div', class_="lister-item mode-advanced") # search by CSS class using the keyword argument class_
# First container: (name, year, IMDB/Metascore ratings, Number of votes, Genere)
# NAME:
movie1 = list(movie_containers)[0] # TAG object
# various HTML tags within it are stored as its attributes.
# movieName1.div, movieName1.a, movie1.h3.a.text
name1 = movie1.h3.a.text
# YEAR:
year1 = movie1.h3.find('span',class_="lister-item-year text-muted unbold").text
# more efficient to do the cleaning after the scraping...
# IMDB/Metascore ratings:
ratingIMDB = movie1.strong.text
#ratingMeta = int(html_soup.find('div', class_="inline-block ratings-metascore").span.text)
ratingMeta = html_soup.find('span', class_="metascore favorable").text
ratingMeta = int(ratingMeta)

# VOTES:                           !!!!!!!!!!!!!!!!!!!!!!!!
votes1 = movie1.find('span', attrs = {'name':'nv'})['data-value']
# we accessed the value of the data-value attribute. This way we can convert the 
# extracted datapoint to an int without having to strip a comma.
genre1 = movie1.find('span',class_="genre").text
genre1 = genre1.strip(" '\n")
# noMetaScore = movie_containers[22].find('div',class_="metascore favorable") <--- NONETYPE!
# The script for a single page:
# We need to add a condition to skip movies without a Metascore...
'''
'''
names = []
years = []
IMDB = []
META = []
votes = []
genres = []

for container in movie_containers:
    if container.find('span',class_='metascore favorable') != None:
        name = container.h3.a.text
        names.append(container.h3.a.text)
        
        year = container.h3.find('span',class_="lister-item-year text-muted unbold").text
        years.append(year)
        
        imdb = float(container.strong.text)
        IMDB.append(imdb)
        
        met = container.find('span', class_="metascore favorable").text
        META.append(met)
        
        vote = container.find('span',attrs={'name':'nv'})['data-value']
        votes.append(int(vote))
        
        genre = container.find('span',class_='genre').text
        genre = genre.strip(" '\n")
        genres.append(genre)
        
# Put into DATAFRAME:
'''
'''
test_df = pd.DataFrame({'Movie':names,'Year':years,'IMDB Rating':IMDB,'Metascore':META,'Votes':votes,'Genre':genres})
print(test_df)
'''
#----------------------------------The script for multiple pages---------------
# As we are making the requests, we’ll only have to vary the values of only two parameters
# of the URL: the release_date parameter, and page...
'''
pages = [str(i) for i in range(1,5)]
release_dates = [str(i) for i in range(2000,2018)]
'''
# Controlling the crawl-rate:   !!!!!!!!!!!!!!!!!
from time import sleep
from random import randint
import time
# SIMULATING A REQUEST:
# Since we’re going to make 72 requests, our work will look a bit untidy as the output accumulates.
# To avoid that, we’ll clear the output after each iteration, and replace it with information about the most recent request
# IPython.core.display.clear_output(wait=False) = Wait to clear the output until new output is available to replace it.
from IPython.core.display import clear_output
'''
requests = 0
for _ in range(5):
    # request
    requests += 1
    sleep(randint(1,3))
    elapsed_time = time.time() - start_time
    print('Request: {}; Frequency: {} requests/second'.format(requests, requests/elapsed_time))
clear_output(wait=True) # ????????????????????????????????????
'''
import warnings as war
# To monitor the status code we’ll set the program to warn us if it throws a warning if the status code is not 200:
# We chose a warning over breaking the loop because there’s a good possibility we’ll scrape enough data,
# even if some of the requests fail.
# Piecing everything together...
pages = [str(i) for i in range(1,5)]
release_dates = [str(i) for i in range(2000,2018)]

names = []
years = []
IMDB = []
META = []
votes = []
genres = []

start_time = time.time()
requests = 0

for release_date in release_dates:
    for page in pages:
        response = get('https://www.imdb.com/search/title/?release_date=' + release_date + 
                       '&sort=num_votes,desc&page=' + page + '&ref_=adv_nxt')
        
        sleep(randint(8,15))
        requests += 1
        elapsed_time = time.time() - start_time
        print('Request: {}; Frequency: {} requests/second'.format(requests, requests/elapsed_time))
        clear_output(wait=True)
        
        # 200: Standard response for successful HTTP requests
        if response.status_code != 200:
            war.warn('Request: {}; Status Code: {}'.format(requests, response.status_code))
        
        if requests > 72:
            war.warn('Number of requests exceeded the limit')
            break
        
        page_html = BS(response.text, 'lxml')
        movieContainers = page_html.find_all('div',class_="lister-item mode-advanced")
        
        for container in movieContainers:
            if container.find('span', class_="metascore  favorable") is not None:
                name = container.h3.a.text
                names.append(name)
                
                year = container.h3.find('span', class_="lister-item-year text-muted unbold").text
                years.append(year)
                
                imdb = float(container.strong.text)
                IMDB.append(imdb)
                
                meta = container.find('span', class_="metascore  favorable").text
                META.append(int(meta))
                
                vote = container.find('span', attrs = {'name':'nv'})['data-value']
                vote.append(int(vote))
                
                genre = container.find('span',class_="genre").text
                genre = genre1.strip(" '\n")
                genres.append(genre)
                
movieRatings = pd.DataFrame({'Movie':names,'Year':years,'IMDB Rating':IMDB,'Meta Score Rating':META,
                             'Vote':votes,'Genre':genres})
print(movieRatings.info())
movieRatings.head(10)


        
