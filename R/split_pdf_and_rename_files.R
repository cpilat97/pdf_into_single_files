library(here)
library(pdftools)
library(tidyverse)

#I'm only going to use the first one hundred pages for this so i don't have to clean up 2000 pdfs, 
#but other than the subset, the process should remain the same. 
pdf_subset(input = 'files/tmp_fee_FEE _Notice_2021_1001_to_2000.pdf', pages = 1:100 , output = 'files/fees_100.pdf')


#Read in the pdf text. This'll read in the text of each page. All the text is stored in a vector that 
#should be the same length as the file numbers you're reading in. 
pdf_page_text = pdf_text(pdf = 'files/fees_100.pdf')

length(pdf_metadata)  #quick check

#get case numbers from the pdf text for later renaming: 
#The regex in the str extract is looking for numbers immediately proceeding text that says
#"Case #: " or "de caso: " 
case_numbers = str_extract(pdf_page_text, '(?<=Case #:\\s)\\d+|(?<=de caso:\\s)\\d+')

#alternatively, if you want to keep the "case #: " or the "de caso" so you know if its the spanish file, 
#we can do (also just going to do a bit of cleaning for them): 
case_nums_alt = str_extract(pdf_page_text, 'Case #:\\s\\d+|de caso:\\s\\d+') %>% #extracts the case num and language
  str_replace_all(., "\\s#:\\s|(?<=caso):\\s", "_num_") %>% #replaces the hash and colon with "_num_" and replaces the colon-space after "caso" with _num_
  str_replace_all(., "\\s", "_") %>% #gets rid of all spaces
  str_to_lower(.) %>% 
  str_c('files/split_files/', ., '.pdf')

#now to split the pdf into individual pages, read them in as a list, and then rename them
#I'm going to put them into their own folder to make things easier to work with a bit later on: 
split_files = pdf_split(input = 'files/fees_100.pdf', output = 'files/split_files/')

#now time to rename them by iterating over the files. 
renamed_files = map2(.x = split_files, 
                     .y = case_nums_alt, 
                     ~ file.rename(from = .x, 
                                   to = .y))

#cleanup/delete all teh files in this path so their not on my computer

map(.x = list.files(path = 'files/split_files', pattern = ".pdf", full.names = TRUE), 
    ~ file.remove(.x))




