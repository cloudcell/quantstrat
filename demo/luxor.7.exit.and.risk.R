#!/usr/bin/Rscript --vanilla
#
# Jan Humme (@opentrades) - April 2013
#
# Tested and found to work correctly using blotter r1457
#
# After Jaekle & Tamasini: A new approach to system development and portfolio optimisation (ISBN 978-1-905641-79-6)
#
# Paragraph 3.5: determination of appropriate exit and risk management

require(quantstrat)

source(paste0(path.package("quantstrat"),"/demo/luxor.include.R"))

source(paste0(path.package("quantstrat"),"/demo/luxor.getSymbols.R"))

### blotter

initPortf(portfolio.st, symbols='GAZP', currency='RUB')
initAcct(account.st, portfolios=portfolio.st, currency='RUB')

### quantstrat

load.strategy('luxor')

### BEGIN uncomment lines to activate StopLoss and/or StopTrailing and/or TakeProfit rules

#enable.rule('luxor', 'chain', 'StopLoss')
#enable.rule('luxor', 'chain', 'StopTrailing')
#enable.rule('luxor', 'chain', 'TakeProfit')

### END uncomment lines to activate StopLoss and/or StopTrailing and/or TakeProfit rules

addPosLimit(
            portfolio=portfolio.st,
            symbol='GAZP',
            timestamp=startDate,
            maxpos=.orderqty)

initOrders(portfolio.st)

applyStrategy(strategy.st, portfolio.st, prefer='Open')

View(getOrderBook(portfolio.st)[[portfolio.st]]$GAZP)

###############################################################################

updatePortf(portfolio.st, Symbols='GAZP', Dates=paste('::',as.Date(Sys.time()),sep=''))

chart.Posn(portfolio.st, "GAZP")

###############################################################################

View(t(tradeStats(portfolio.st, 'GAZP')))

###############################################################################

print(tradeQuantiles('forex', 'GAZP'))

dev.new()

### Uncomment to choose appropriate MAE of MFE graph

chart.ME(portfolio.st, 'GAZP', scale='percent', type='MAE')
dev.new()
chart.ME(portfolio.st, 'GAZP', scale='percent', type='MFE')
