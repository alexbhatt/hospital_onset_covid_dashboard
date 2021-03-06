about <- function(title, content) {
  tagList(
    tags$title("About the data - Healthcare associated COVID-19 Surveillance in England"),
    h1(
        class="govuk-caption-l govuk-!-margin-0 govuk-!-padding-top-3",
        "About the data"
    ),
    tags$hr(
        class="govuk-section-break govuk-section-break--m govuk-!-margin-top-2 govuk-!-margin-bottom-4 govuk-section-break--visible"
    ),
    tags$div(
        class="markdown util-text-max-width",
        includeMarkdown("content/about.md")
    )
  )
}
