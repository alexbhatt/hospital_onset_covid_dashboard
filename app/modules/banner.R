# banner.R
banner <- function(inputId, type, label) {
  tagList(
    tags$div(
      class="govuk-phase-banner govuk-width-container govuk-main-wrapper",
      id = inputId,
      tags$p(
        class="govuk-phase-banner__content",
        tags$strong(
          class="govuk-tag govuk-phase-banner__content__tag ",
          type
        ),
        tags$span(
          class="govuk-phase-banner__text",
          HTML(label),
          tags$strong("This dashboard and all associated data is for internal-PHE use only.")
        )
      )
    )
  )
}
