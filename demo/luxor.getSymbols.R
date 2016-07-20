#!/usr/bin/Rscript --vanilla
#
# Jan Humme (@opentrades) - August 2012, revised April 2013
#
# Tested and found to work correctly using blotter r1457
#
# After Jaekle & Tamasini: A new approach to system development and portfolio optimisation (ISBN 978-1-905641-79-6)
#
# loading symbol data

Sys.setenv(TZ="UTC")

### packages
#
# quantstrat package will pull in some other packages:
# FinancialInstrument, quantmod, blotter, xts

require(quantstrat)

### FinancialInstrument

# currency(c('GBP', 'USD'))
currency(c('RUB'))
stock(c('GAZP'), currency = 'RUB')
smb = 'GAZP'
# exchange_rate('GBPUSD', tick_size=0.0001)

### quantmod

getSymbols.FI(Symbols=smb,
	      # dir=system.file('extdata',package='quantstrat'),
        #dir=system.file('extdata_full', package='quantstrat'),
        dir='e:/d-sto-R/moex/',
#	      dir='~/R/OHLC',
	      from=.from, to=.to
)

# ALTERNATIVE WAY TO FETCH SYMBOL DATA
#setSymbolLookup.FI(system.file('extdata',package='quantstrat'), 'GBPUSD')
#getSymbols('GBPUSD', from=.from, to=.to, verbose=FALSE)

### xts

# SBER = to.minutes(SBER)
# SBER = to.minutes5(SBER)
#
# to.period(x,
#           period = 'months',
#           k = 1,
#           indexAt,
#           name=NULL,
#           OHLC = TRUE,
#           ...)
# Arguments
#      x         -- a univariate or OHLC type time-series object
#      period    -- period to convert to. See details.
#      indexAt   -- convert final index to new class or date. See details
#      drop.time -- remove time component of POSIX datestamp (if any)
#      k         -- number of sub periods to aggregate on (only for minutes and seconds)
#      name      -- override column names
#      OHLC	     -- should an OHLC object be returned? (only OHLC=TRUE currently supported)
#      ...       -- additional arguments
#



._seconds = 60 * 15

GAZP = to.period(GAZP, period = 'seconds', k = ._seconds )

# align.time(x, ...)
# x -- object to align
# n -- number of seconds to adjust by
# ... -- additional arguments. See details.

GAZP = align.time(GAZP, ._seconds)    
