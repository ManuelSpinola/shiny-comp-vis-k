# función sacada de kuzco package
my_view_llm_results <-function(llm_results) {
  # create a long data.frame for the llm_results
  llm_results_long <-
    llm_results |>
    dplyr::mutate(
      dplyr::across(
        dplyr::everything(),
        as.character
      )
    ) |>
    tidyr::pivot_longer(
      cols = dplyr::everything(),
      names_to = "Contexto",
      values_to = "Respuesta"
    )
  
  # TODO: what-if llm_results contains multiple results?
  # if, n = 1 ?
  # else, create a different table for n > 1 ?
  llm_results_long |>
    dplyr::mutate(
      Contexto = stringr::str_replace_all(Contexto, "_", " "),
      Contexto = stringr::str_to_title(Contexto)
    ) |>
    gt::gt() |>
    gt::tab_header(
      title = gtExtras::add_text_img(
        "Visión por computadora ",
        url = "logo01.png",
        height = 30
      )
    ) |>
    gt::tab_options(
      column_labels.background.color = "#B71234"
    ) |>
    gt::tab_style(
      style = gt::cell_text(color = "white", weight = "bold"),
      locations = gt::cells_column_labels()) |>
    gt::tab_style(
      style = gt::cell_text(
        color = '#B71234',
        weight = 'bold'
      ),
      locations = gt::cells_title(groups = 'title')
    )
}