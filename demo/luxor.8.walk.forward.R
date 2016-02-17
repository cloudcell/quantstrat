#!/usr/bin/Rscript --vanilla
#
# Jan Humme (@opentrades) - April 2013
#
# Tested and found to work correctly using blotter r1457
#
# After Jaekle & Tamasini: A new approach to system development and portfolio optimisation (ISBN 978-1-905641-79-6)
#
# Paragraph 3.7 walk forward analysis

require(quantstrat)

source(paste0(path.package("quantstrat"),"/demo/luxor.include.R"))
source(paste0(path.package("quantstrat"),"/demo/luxor.getSymbols.R"))
source(paste0(path.package("quantstrat"),"/demo/luxor.5.strategy.ordersets.R"))

### foreach and doMC

require(foreach)
require(doMC)
registerDoMC(cores=8)

### robustbase and PerformanceAnalytics

if (!requireNamespace("robustbase", quietly=TRUE))
  stop("package 'robustbase' required, but not installed")
if (!requireNamespace("PerformanceAnalytics", quietly=TRUE))
  stop("package 'PerformanceAnalytics' required, but not installed")

### blotter

initPortf(portfolio.st, symbols='GBPUSD', currency='USD')
initAcct(account.st, portfolios=portfolio.st, currency='USD', initEq=100000)

### quantstrat

initOrders(portfolio.st)

# no need to load strategy as the sourced file "luxor.5.strategy.ordersets.R"
# builds it from scratch anyway
# load.strategy(strategy.st)

enable.rule(strategy.st, 'chain', 'StopLoss')
#enable.rule(strategy.st, 'chain', 'StopTrailing')
enable.rule(strategy.st, 'chain', 'TakeProfit')

addPosLimit(
            portfolio=portfolio.st,
            symbol='GBPUSD',
            timestamp=startDate,
            maxpos=.orderqty)

### objective function

ess <- function(account.st, portfolio.st)
{
    # this function may cause failure of 'foreach' on small datasets
    # at combine stage, try allowing it to run to see a crash demonstration.
    # TODO: post an issue at github to handle errors within user functions
    #       without crashing 'foreach'
    # TODO: fix this function by allowing it to handle small datasets
    # return(0)

    require(robustbase, quietly=TRUE)
    require(PerformanceAnalytics, quietly=TRUE)

    portfolios.st <- ls(pos=.blotter, pattern=paste('portfolio', portfolio.st, '[0-9]*',sep='.'))

    # for debugging only (delete later)
    print("portfolio.st: "); print(portfolios.st)

    # 'pr' is an xts object with the header 'GBPUSD.DailyEndEq'
    pr <- PortfReturns(Account = account.st, Portfolios=portfolios.st)

    # for debugging only (delete later)
    print("str(pr): "); print(str(pr))
    print("pr: "); print(pr)


    # only run if not all pr values are equal to zero
    # this condition prevents the error from happening
    # (perhaps it could be replaced with something more efficient)
    # if(!all(pr==0)) {
    if(1) { # uncomment this line to demonstrate the error
        cat("<<<<<<<<<< Trying to run ES()... >>>>>>>>>>\n")
        try(
            # FIXME: "ES()" must handle exceptions properly!
            #
            # This log documents the bug: https://www.irccloud.com/pastebin/qboUGK9Y/
            # "Processing param.combo 15"
            my.es <- ES(R=pr, clean='boudt')
        )
        if(inherits(my.es,what = "try-error")) {

            # for debugging only (delete later)
            print("my.es contains an error!")
            print("str(my.es): "); print(str(my.es))
            print("my.es: "); print(my.es)

            # -----------------------------------------------------------------#
            # **___The following comment belongs in a manual (selectively)___**
            # FIXME: This is a temporary hack. Functions must handle exceptions
            # themselves and produce NAs in exceptional cases. Because
            # rbind() within apply.paramset() needs a variable _name_
            # which cannot be given if a function simply returns NA upon failure
            #
            # So, once again, exceptions must be handled within functions !
            # And functions must return NAs (where applicable)
            #
            # rbind() function that binds all the results in "apply.paramset()"
            # should have results for all the combos, even if some fail.
            # the user must not spend time figuring out where one of the
            # results disappeared
            #
            # Alternatively, one may simply use NA's here instead of NULL
            # and bind as is without proper column names simply using existing
            # column names in the apply.paramset results$user.func dataframe
            # http://stackoverflow.com/questions/19297475/simplest-way-to-get-rbind-to-ignore-column-names
            # However, if the initial results$user.func() data frame row
            # contains results from a failed attempt to calculate user.func(),
            # this approach will not work. So this approach is not acceptable.
            #
            # Conclusion: handle errors within functions themselves and
            # assign proper names to the output so combine function
            # combines them properly. Until then, this hack will simply
            # omit failed tests simply by supplying NULL instead of NA (which
            # would be most appropriate)
            #
            # -----------------------------------------------------------------#
            # This hack could be improved: ES does not change the name of
            # the output field in the dataframe, so we could simply assign
            # the same "name" to the variable "my.es"; however, there could be
            # exceptions in other functions, where we would not be able to
            # know what field names the function produces, so we better
            # return to fixing error handling within functions themselves.
            # -----------------------------------------------------------------#
            my.es <- NULL # crude temporary hack (see comment above)
            cat("<<<<<<<<<< The results from this user.func are NULL'ed: The call to ES failed. >>>>>>>>>>\n")
        }
    } else {
        # FIXME: See the same note as in the "FIXME" just above.
        cat("<<<<<<<<<< The results from this user.func are NULL'ed: The input argument ('pr') was all zeroes >>>>>>>>>>\n")
        my.es <- NULL  # crude temporary hack (see comment above)
    }

    # for debugging only (delete later)
    print("str(my.es): "); print(str(my.es))
    print("my.es: "); print(my.es)

    # if the result is equal to NULL, such result is skipped at the combine
    # stage, and the error does not cause problems: but this is a hack
    # (also, read FIXME's above)
    return(my.es)
}

my.obj.func <- function(x)
{
    # pick one of the following objective functions (uncomment)

    # result <- (max(x$tradeStats$Max.Drawdown) == x$tradeStats$Max.Drawdown)

    # result <- (max(x$tradeStats$Net.Trading.PL) == x$tradeStats$Net.Trading.PL)

    # result <- (max(x$user.func$GBPUSD.DailyEndEq) == x$user.func$GBPUSD.DailyEndEq)

    #-------------------------------------------------------------------------#
    # A step-by-step approach to defining the objective function

    # Select portfolios related to the symbol
    # (important for multi-instrument portfolios)
    input <- x$tradeStats[(x$tradeStats$Symbol == 'GBPUSD'),]

    # Choose decision parameter (uncomment)
    # param <- input$Profit.Factor
    param <- input$Max.Drawdown # Drawdown is expressed as a negative value
    # param <- input$Net.Trading.PL

    print("param:"); print(param) # for debugging only

    # Simple decision rule (uncomment / adjust as needed)
    result <- (max(param) == param)
    # result <- (min(param) == param)


    # Leaving only a single optimum
    if(length(which(result == TRUE)) > 1) {
        # ambiguous objective function
        warning("discarding extra objective function result(s)")
        uniqueIdx <- min(which(result == TRUE))
        result[] <- FALSE
        result[uniqueIdx] <- TRUE
    }

    # return the selection vector
    result
}

### walk.forward

r <- walk.forward(strategy.st,
                  paramset.label='WFA',
                  portfolio.st=portfolio.st,
                  account.st=account.st,
                  period='days',
                  k.training=3,
                  # 1 day does not contain enough data points to calculate SMA
                  # with a length of over 40, ( see this log
                  # https://www.irccloud.com/pastebin/REaa4uZV/debugging )
                  # TODO: report such cases clearly or proactively determine
                  # that indicators might produce such errors
                  k.testing=3, #1,
                  obj.func=my.obj.func,
                  obj.args=list(x=quote(result$apply.paramset)),
                  user.func=ess,
                  user.args=list('account.st'=account.st, 'portfolio.st'=portfolio.st),
                  audit.prefix='wfa',
                  # anchored=TRUE,
                  anchored=FALSE,
                  verbose=TRUE)

### analyse
print("saving a chart as a pdf file")
pdf(paste('GBPUSD', .from, .to, 'pdf', sep='.'))
dev.off()

print("drawing a chart on the screen")
par(ask=FALSE) # avoid having to hit 'Enter'
chart.Posn(portfolio.st)

print("saving tradeStats")
ts <- tradeStats(portfolio.st)
save(ts, file=paste('GBPUSD', .from, .to, 'RData', sep='.'))

print("# end of demo #")
