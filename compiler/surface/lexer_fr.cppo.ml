(* -*- coding: iso-latin-1 -*- *)

(* This file is part of the Catala compiler, a specification language for tax and social benefits
   computation rules. Copyright (C) 2020 Inria, contributors: Denis Merigoux
   <denis.merigoux@inria.fr>, Emile Rolley <emile.rolley@tuta.io>

   Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
   in compliance with the License. You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software distributed under the License
   is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
   or implied. See the License for the specific language governing permissions and limitations under
   the License. *)

(* WARNING: this file must be saved as Latin-1 and not utf8, sedlex requires it *)

(* Defining the lexer macros for French *)


(* Tokens and their corresponding sedlex regexps *)

#define MS_SCOPE "champ d'application"
#define MR_SCOPE "champ", space_plus, "d'application"
#define MS_CONSEQUENCE "cons�quence"
#define MS_DATA "donn�e"
#define MS_DEPENDS "d�pend de"
#define MR_DEPENDS "d�pend", space_plus, "de"
#define MS_DECLARATION "d�claration"
#define MS_CONTEXT "contexte"
#define MS_DECREASING "d�croissant"
#define MS_INCREASING "croissant"
#define MS_OF "de"
#define MS_COLLECTION "collection"
#define MS_ENUM "�num�ration"
#define MS_INTEGER "entier"
#define MS_MONEY "argent"
#define MS_TEXT "texte"
#define MS_DECIMAL "d�cimal"
#define MS_DATE "date"
#define MS_DURATION "dur�e"
#define MS_BOOLEAN "bool�en"
#define MS_SUM "somme"
#define MS_FILLED "rempli"
#define MS_DEFINITION "d�finition"
#define MS_LABEL "�tiquette"
#define MS_EXCEPTION "exception"
#define MS_DEFINED_AS "�gal �"
#define MR_DEFINED_AS "�gal", space_plus, "�"
#define MS_MATCH "selon"
#define MS_WILDCARD "n'importe quel"
#define MR_WILDCARD "n'importe", space_plus, "quel"
#define MS_WITH "sous forme"
#define MR_WITH "sous", space_plus, "forme"
#define MS_UNDER_CONDITION "sous condition"
#define MR_UNDER_CONDITION "sous", space_plus, "condition"
#define MS_IF "si"
#define MS_THEN "alors"
#define MS_ELSE "sinon"
#define MS_CONDITION "condition"
#define MS_CONTENT "contenu"
#define MS_STRUCT "structure"
#define MS_ASSERTION "assertion"
#define MS_VARIES "varie"
#define MS_WITH_V "avec"
#define MS_FOR "pour"
#define MS_ALL "tout"
#define MS_WE_HAVE "on a"
#define MR_WE_HAVE "on", space_plus, "a"
#define MS_FIXED "fix�"
#define MS_BY "par"
#define MS_RULE "r�gle"
#define MS_EXISTS "existe"
#define MS_IN "dans"
#define MS_SUCH "tel"
#define MS_THAT "que"
#define MS_AND "et"
#define MS_OR "ou"
#define MS_XOR "ou bien"
#define MR_XOR "ou", space_plus, "bien"
#define MS_NOT "non"
#define MS_MAXIMUM "maximum"
#define MS_MINIMUM "minimum"
#define MS_FILTER "filtre"
#define MS_MAP "application"
#define MS_INIT "initial"
#define MS_CARDINAL "nombre"
#define MS_YEAR "an"
#define MS_MONTH "mois"
#define MS_DAY "jour"
#define MS_TRUE "vrai"
#define MS_FALSE "faux"

(* Specific delimiters *)

#define MR_MONEY_OP_SUFFIX 0x20AC (* The euro sign *)
#define MS_DECIMAL_SEPARATOR ","

(* Builtins *)

#define MS_IntToDec "entier_vers_d�cimal"
#define MS_GetDay "acc�s_jour"
#define MS_GetMonth "acc�s_mois"
#define MS_GetYear "acc�s_ann�e"

(* Directives *)

#define MR_BEGIN_METADATA "D�but", Plus hspace, "m�tadonn�es"
#define MR_END_METADATA "Fin", Plus hspace, "m�tadonn�es"
#define MR_LAW_INCLUDE "Inclusion"
#define MX_AT_PAGE \
   '@', Star hspace, "p.", Star hspace, Plus digit -> \
      let s = Utf8.lexeme lexbuf in \
      let i = String.index s '.' in \
      AT_PAGE (int_of_string (String.trim (String.sub s i (String.length s - i))))

(* More complex cases *)

#define MX_MONEY_AMOUNT \
   digit, Star (digit | hspace), Opt (MS_DECIMAL_SEPARATOR, Rep (digit, 0 .. 2)), Star hspace, 0x20AC -> \
      let extract_parts = \
        Re.(compile @@ seq [ \
            group (seq [ digit; opt (seq [ rep (alt [digit; char ' ']); digit]) ]); \
            opt (seq [ str MS_DECIMAL_SEPARATOR; group (repn digit 0 (Some 2))]) \
        ]) \
      in \
      let str = Utf8.lexeme lexbuf in \
      let parts = R.get_substring (R.exec ~rex:extract_parts str) in \
      (* Integer literal*) \
      let units = parts 1 in \
      let remove_spaces = R.regexp " " in \
      let units = \
        Runtime.integer_of_string (R.substitute ~rex:remove_spaces ~subst:(fun _ -> "") units) \
      in \
      let cents = \
        try Runtime.integer_of_string (parts 2) with Not_found -> Runtime.integer_of_int 0 \
      in \
      L.update_acc lexbuf; \
      MONEY_AMOUNT (units, cents)
