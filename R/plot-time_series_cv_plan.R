#' Visualize a Time Series Resample Plan
#'
#' The `plot_time_series_cv_plan()` function provides a visualization
#' for a time series resample specification (`rset`) of either `rolling_origin`
#' or `time_series_cv` class.
#'
#' @inheritParams plot_time_series
#' @param .rset A time series resample specification of of either `rolling_origin`
#' or `time_series_cv` class or a data frame (tibble) that has been prepared
#' using [tk_time_series_cv_plan()].
#' @param ... Additional parameters passed to [plot_time_series()]
#'
#' @details
#'
#' __Resample Set__
#'
#' A resample set is an output of the `timetk::time_series_cv()` function or the
#' `rsample::rolling_origin()` function.
#'
#' @seealso
#' - [time_series_cv()] and [rsample::rolling_origin()] - Functions used to create
#'   time series resample specfications.
#' - [plot_time_series_cv_plan()] - The plotting function used for visualizing the
#'   time series resample plan.
#'
#' @examples
#' library(tidyverse)
#' library(tidyquant)
#' library(rsample)
#' library(timetk)
#'
#' FB_tbl <- FANG %>%
#'     filter(symbol == "FB") %>%
#'     select(symbol, date, adjusted)
#'
#' resample_spec <- time_series_cv(
#'     FB_tbl,
#'     initial = "1 year",
#'     assess  = "6 weeks",
#'     skip    = "3 months",
#'     lag     = "1 month",
#'     cumulative  = FALSE,
#'     slice_limit = 6
#' )
#'
#' resample_spec %>% tk_time_series_cv_plan()
#'
#' resample_spec %>%
#'     tk_time_series_cv_plan() %>%
#'     plot_time_series_cv_plan(
#'         date, adjusted, # date variable and value variable
#'         # Additional arguments passed to plot_time_series(),
#'         .facet_ncol = 2,
#'         .line_alpha = 0.5,
#'         .interactive = FALSE
#'     )
#'
#' @export
plot_time_series_cv_plan <- function(.rset, .date_var, .value, ...,
                                     .smooth = FALSE,
                                     .title = "Time Series Cross Validation Plan") {

    UseMethod("plot_time_series_cv_plan", .rset)
}

#' @export
plot_time_series_cv_plan.rolling_origin <- function(.rset, .date_var, .value, ...,
                                                    .smooth = FALSE,
                                                    .title = "Time Series Cross Validation Plan") {

    plot_ts_cv_rset(
        .rset,
        .date_var   = !! rlang::enquo(.date_var),
        .value      = !! rlang::enquo(.value),
        ...,
        .smooth     = .smooth,
        .title      = .title
    )



}

#' @export
plot_time_series_cv_plan.time_series_cv <- function(.rset, .date_var, .value, ...,
                                                    .smooth = FALSE,
                                                    .title = "Time Series Cross Validation Plan") {

    plot_ts_cv_rset(
        .rset,
        .date_var   = !! rlang::enquo(.date_var),
        .value      = !! rlang::enquo(.value),
        ...,
        .smooth     = .smooth,
        .title = "Time Series Cross Validation Plan"
    )


}

#' @export
plot_time_series_cv_plan.data.frame <- function(.rset, .date_var, .value, ...,
                                                .smooth = FALSE,
                                                .title = "Time Series Cross Validation Plan") {

    plot_ts_cv_dataframe(
        .rset,
        .date_var   = !! rlang::enquo(.date_var),
        .value      = !! rlang::enquo(.value),
        ...,
        .smooth     = .smooth,
        .title = "Time Series Cross Validation Plan"
    )


}


#' @export
plot_time_series_cv_plan.default <- function(.rset, .date_var, .value, ...,
                                             .smooth = FALSE,
                                             .title = "Time Series Cross Validation Plan") {
    rlang::abort("plot_time_series_cv_plan: No method for class, ", class(.rset)[1])
}


plot_ts_cv_rset <- function(.rset, .date_var, .value, ...,
                            .smooth = FALSE,
                            .title = "Time Series Cross Validation Plan") {

    date_var_expr <- rlang::enquo(.date_var)
    value_expr    <- rlang::enquo(.value)

    # Format data
    data_formatted <- tk_time_series_cv_plan(.rset)

    data_formatted %>%
        dplyr::ungroup() %>%
        dplyr::group_by(.id) %>%
        plot_time_series(
            .date_var   = !! date_var_expr,
            .value      = !! value_expr,
            .color_var  = .key,
            ...,
            .smooth     = .smooth,
            .title      = .title)

}

plot_ts_cv_dataframe <- function(.rset, .date_var, .value, ...,
                                 .smooth = FALSE,
                                 .title = "Time Series Cross Validation Plan") {

    date_var_expr <- rlang::enquo(.date_var)
    value_expr    <- rlang::enquo(.value)

    # Format data
    data_formatted <- .rset

    # Checks
    id_key_in_data <- all(c(".id", ".key") %in% names(data_formatted))
    if (!id_key_in_data) rlang::abort("The data frame must have 'id' and 'key' columns. Try using `tk_time_series_cv_plan()` to unpack the `.rset`.")

    data_formatted %>%
        dplyr::ungroup() %>%
        dplyr::group_by(.id) %>%
        plot_time_series(
            .date_var   = !! date_var_expr,
            .value      = !! value_expr,
            .color_var  = .key,
            ...,
            .smooth     = .smooth,
            .title      = .title)

}
