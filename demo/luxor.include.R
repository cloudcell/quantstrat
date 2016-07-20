###

options(width = 240)
#options(warn=1)

Sys.setenv(TZ="UTC")

###

initDate = '2015-01-01'
initDate = '2011-01-01'
initDate = '2013-01-01'
initDate = '2014-01-01'
initDate = '2014-01-01'
#initDate = '2015-01-04'
initDate = '2011-01-01'
initDate = '2010-01-01'
initDate = '2016-01-01' 

initDate = '2016-01-01'


.from=initDate

#.to='2008-07-04'
#.to='2002-10-31'
#.to='2003-03-31'
.to = '2015-12-31'
# .to='2014-03-31'
# .to='2015-06-30'
.to = '2010-12-31'
.to = '2012-12-31'
.to = '2013-12-31'
.to = '2014-12-31'  
#.to = '2015-12-30'
.to = '2016-12-31'

###

strategy.st = 'sma1'
portfolio.st = 'pSma1'
account.st = 'FA' #FinAm

###

.orderqty = 10
.threshold = 0.0005
.txnfees = -1		# round-trip fee

### Distributions for paramset analysis

.nsamples=80

.FastSMA = (23:35) #1:29
.SlowSMA = (30:41) #30:80

.FastSMA = (1:10) #1:29
.SlowSMA = (1:10) #30:80

.FastSMA = (35:35) #1:29
.SlowSMA = (60:65) #30:80

.FastSMA = (1:80) #1:29 1-50
.FastSMA = (1:200) #1:29 1-50
.SlowSMA = (20:200) #30:80 20-80

.FastSMA = (1:400) #1:29 1-50
.SlowSMA = (40:400) #30:80 20-80

.StopLoss = seq(0.05, 2.4, length.out=48)/100
.StopTrailing = seq(0.05, 2.4, length.out=48)/100
.TakeProfit = seq(0.1, 4.8, length.out=48)/100

.FastWFA = c(1, 3, 5, 7, 9)
.SlowWFA = c(42, 44, 46)

# generate 24x24h ISO8601 timespan vector

.timespans.start<-paste(sprintf("T%02d",0:23),':00',sep='')
.timespans.stop<-paste(sprintf("T%02d",0:23),':59',sep='')

.timespans<-outer(.timespans.start, .timespans.stop, FUN=paste, sep='/')

# in order to run the full 24x24 hour scan above, comment out the following line:
.timespans<-c('T06:00/T10:00',  'T07:00/T11:00',
	      'T08:00/T12:00',  'T09:00/T13:00',
              'T10:00/T14:00',  'T11:00/T15:00', 
              'T12:00/T16:00',  'T13:00/T17:00', 
	      'T14:00/T18:00',  'T15:00/T19:00', 
              'T16:00/T20:00',  'T17:00/T21:00', 
              'T18:00/T22:00',  'T19:00/T23:00', 
              'T20:00/T00:00',  'T21:00/T01:00', 
              'T22:00/T02:00',  'T23:00/T03:00', 
              'T00:00/T04:00',  'T01:00/T05:00', 
              'T02:00/T06:00',  'T03:00/T07:00',  
	      'T04:00/T08:00',  'T05:00/T09:00')

### Actual arameters

.fast = 6
.slow = 44

#.timespan = 'T09:00/T13:00'
#.timespan = 'T00:00/T23:59'
.timespan = NULL

.stoploss <- 0.40/100
.stoptrailing <- 0.8/100
.takeprofit <- 2.0/100

suppressWarnings(rm(list = c(paste("account", account.st, sep='.'), paste("portfolio", portfolio.st, sep='.')), pos=.blotter))
suppressWarnings(rm(list = c(strategy.st, paste("order_book", portfolio.st, sep='.')), pos=.strategy))
