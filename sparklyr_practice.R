library(sparklyr)
library(dplyr)

# Setup connection
spark_conn <- spark_connect(master = "local")

# Copy mtcars dataset from R into a Spark session. The result is a tibble
cars <- copy_to(spark_conn, mtcars)

# Data Manipulation -------------------------------------------------------


# Find the mean of each variable
mean_summarized <- summarize_all(cars, mean, na.rm=T) 

# You can display the corresponding query using "show_query()"
mean_summarized %>%
  show_query()

# Create a new variable "transmission" and find the mean of every other variable
cars %>%
  mutate(transmission = ifelse(am == 0, "automatic", "manual")) %>%
  group_by(transmission) %>%
  summarize_all(mean)

# Determine which transmission type has the highest mpg and the corresponding number of cylinders. Note 
# that you have to filter a sparklyr dataframe with "select". You can not use "$" or index with brackets
cars %>%
  select(am, mpg, cyl) %>%
  arrange(desc(mpg))
is.null(cars$mpg)


# Only get the mpg where the displacement >= 3.5 cu.in. and number of forward gears > 3
cars %>%
  select(mpg, drat, gear) %>%
  arrange(desc(mpg)) %>%
  filter(drat >= 3.5, gear > 3)

# Copy Spark data to R's memory. You can treat this variable as a data frame
normal_dataframe <- collect(cars)
is.null(normal_dataframe$mpg)

# Machine Learning --------------------------------------------------------

# Returns training and testing set
training_and_testing <- cars %>%
  sdf_random_split(training = 0.75, testing = 0.25, seed = 12)

# Get training set
training_set <- training_and_testing$training

# Get testing set
testing_set <- training_and_testing$testing

# Linear Regression
# Note that the object returned is almost identical to the object returned when performing "lm()" or "glm()"
spark_linear_regression <- cars %>%
  ml_linear_regression(formula = mpg ~.) 

# Get the predictions from linear regression
linear_predictions <- predict(spark_linear_regression, testing_set)

# Get the mpg values of the testing set as a list
testing_set_mpg <- pull(testing_set, mpg)

# Plot the predictions
plot(linear_predictions, testing_set_mpg) 
abline(0,1)

# Logistic Regression
spark_logistic_regression <- cars %>%
  ml_logistic_regression(formula = am ~.)

# Get the logistic regression prediction
logistic_predictions <- ml_predict(spark_logistic_regression, testing_set)

# Decision Tree
spark_decision_tree <- cars %>%
  ml_decision_tree(formula = am ~., max_depth = 3)

# Disconnect the Spark session
spark_disconnect(sc = spark_conn)
