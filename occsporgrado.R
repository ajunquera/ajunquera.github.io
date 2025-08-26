library(haven)
library(janitor)
library(tidyverse)
library(srvyr)

# Reading data ------------
eilu19 <- read_dta("data/EILU_GRAD_2019.dta")

fields <- read_xlsx("data/dr_EILU_GRAD_2019.xlsx",
                         sheet = "Tablas3",
                         range = "A6:B107") # CNED-2014

# "Para los graduados se ha usado la CNED-2014 por sector específico (dos
# niveles de desagregación). En algunos casos más relevantes por sector
# detallado (tres niveles)." (p. 22, methods document)

cno2 <- read_csv("data/cno-sispe-8d.csv") |>
  filter(nchar(code) == 2) # CNO-11 2 digits

# Declaring sampling design ---------
d_eilu19 <- eilu19 %>%
  as_survey_design(ids = 1, weights = FACTOR)

# Chequeo: total de empleados, desempleados e inactivos
d_eilu19 %>%
  group_by(TRBPRN1) %>%
  survey_tally()

est_titu_eilu19 <- d_eilu19 %>%
  group_by(TRBPRN1, TITU) %>%
  survey_tally()

# Particular case ------------
## Bachelor in Political Science

# Población de interés: graduados en CP sin otros estudios medios/superiores
ocus_cp <- d_eilu19 %>%
  filter(TITU == "031201") %>% # ciencia política
  filter(EST_B11_7 == "2") %>% # sin otros estudios
  filter(TRBPRN1 == "1") %>% # trabajando
  group_by(TRABOC) %>%
  survey_tally()


ocus_cp_full <- d_eilu19 %>%
  filter(TITU == "031201") %>% # ciencia política
  filter(EST_B11_7 == "2") %>% # sin otros estudios
  filter(TRBPRN1 == "1") %>% # trabajando
  group_by(TRABOC) %>%
  survey_tally() |>
  mutate(prop = round(n/sum(n) * 100, 2)) |>
  mutate(field = "031201") |> # ciencia política
  left_join(fields, by = c("field" = "Código")) |> # Adding name of bachelor
  left_join(cno2, by = c("TRABOC" = "code")) |> # Adding name of occupation
  relocate("description", .after = "TRABOC") |>
  arrange(desc(prop)) |>
  select(-c(n, n_se, field))


# Generalizing -----------
pop_interest <- d_eilu19 %>%
  filter(EST_B11_7 == "2") %>% # sin otros estudios
  filter(TRBPRN1 == "1") # trabajando

all_fields <- unique(eilu19$TITU)

## Loop
list_tables <- list()

for(f in 1:length(all_fields)){

  list_tables[[f]] <- pop_interest %>%
    filter(TITU == all_fields[f]) %>% # bachelor (code)
    group_by(TRABOC) %>%
    survey_tally() |>
    mutate(prop = round(n/sum(n) * 100, 2)) |>
    mutate(field = all_fields[f]) |> # bachelor (code)
    left_join(fields, by = c("field" = "Código")) |> # Adding name of bachelor
    left_join(cno2, by = c("TRABOC" = "code")) |> # Adding name of occupation
    relocate("description", .after = "TRABOC") |>
    arrange(desc(prop)) |>
    select(-c(n, n_se, field))

  cat("\rFinished", f, "of", length(all_fields))

}

table_occs <- bind_rows(list_tables)

colnames(table_occs) <- c("Ocupación (código)",
                          "Ocupación (nombre)",
                          "Porcentaje",
                          "Campo de estudio")

## To save
grado_occs_eilu19 <- table_occs |>
  relocate('Campo de estudio') |>
  arrange(`Campo de estudio`)

colnames(grado_occs_eilu19) <- c("campo", "code", "name", "percent")

### Eliminar saltos de línea
grado_occs_eilu19$name <- gsub("\n", " ", grado_occs_eilu19$name)

write.csv(grado_occs_eilu19, "data/processed/grado_occs_eilu19.csv",
          row.names = F, quote = T)

grado_occs_eilu19j <- jsonlite::toJSON(grado_occs_eilu19, pretty = TRUE, auto_unbox = TRUE)
write(grado_occs_eilu19j, file = "data/processed/grado_occs_eilu19j.json")


# Characterizing the sample ----------
eilu19 |>
  filter(EST_B11_7 == "2") |> # sin otros estudios
  filter(TRBPRN1 == "1") |> # trabajando
  tabyl(TITU)

# Old-style ---------
cp <- d_eilu19 %>%
  filter(TITU == "031201") %>% # ciencia política
  filter(EST_B11_7 == "2") %>% # sin otros estudios
  filter(TRBPRN1 == "1") # trabajando

sectorcp <- as.data.frame(prop.table(xtabs(FACTOR ~ factor(TR_CNAE), data = cp)) * 100)

ocucp <- as.data.frame(prop.table(xtabs(FACTOR ~ factor(TRABOC), data = cp)) * 100)
