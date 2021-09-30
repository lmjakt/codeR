#include <R.h>
#include <Rinternals.h>
#include <strings.h>

// A function that takes a character vector and splits it further
// into a series of words / phrases which should be displayed with
// a different color.
//
// Returns a list containing an entry for each original line
// Each entry in the list contains a character vector (STRSXP)
// and a simple integer vector INTSXP, giving a color for
// each entry in the character vector.


// compares characters until it runs out of characters
// in a or b
size_t prefix_cmp(const char *a, const char *b){
  size_t i = 0;
  while(a[i] && b[i]){
    if(a[i] != b[i])
      return(0);
    ++i;
  }
  // if b[i] is 0, we have reached the end of b[i]
  // return the length of the word, otherwise return 0
  return( b[i] == 0 ? i : 0 );
}

size_t compare_words(const char *str, const char **words, size_t n){
  size_t wl = 0;
  for(size_t i=0; i < n; ++i){
    if( (wl = prefix_cmp(str, words[i])) )
      return(wl);
  }
  return(0);
}

unsigned char char_in(const unsigned char c, const unsigned char *word){
  while(*word != 0 && *word != c)
    ++word;
  return(*word);
}

// returns what kind of class that the character belongs to
// -1 : non-printable
// 0  : a letter (including _)
// 1  : a separator (\n, \t, ' ', (, ), [, ], {, })
// 2  : a member indicator ($, @)
// 3  : a quote character "'
// 4  : an operator 
// 5  : a comment character
// 6  : an escape character
// 7  : unknown
// (These should really be using typedefs, but I
//  like to minimise the amount of code included)
// If the code gets more complex, then this should certainly
// be done.

enum char_class { ALPHA=1, NUM=2, SEP=4, OPERATOR=8, COMMENT_CHAR=16, ESCAPE=32, MEMBER=64, S_QUOTE=128, D_QUOTE=256 };

int char_class(const unsigned char c){
  unsigned int class = 0;
  const unsigned char *separator = (const unsigned char*)" \n\t\r()[]{};-+=*";
  const unsigned char *member = (const unsigned char*)"$@";
  //  const char *quote = "'\"";
  const unsigned char *operator = (const unsigned char*)"!%&*+-/:<>=?^|~";
  const unsigned char *comment = (const unsigned char*)"#";
  const unsigned char *escape = (const unsigned char*)"\\";
  // First check if it is within the range of an alpha-numeric
  if( ((c | 0x20) >= 97 && (c | 0x20) <= 122) || char_in(c, (const unsigned char*)"_.") )
    class |= ALPHA;
  if( c >= 48 && c <= 57 )
    class |= NUM;
  if( c == '\'' ) class |= S_QUOTE;
  if( c == '"') class |= D_QUOTE;
  if( char_in( c, separator ) ) class |= SEP;
  if( char_in( c, member )) class |= MEMBER;
  if( char_in( c, operator )) class |= OPERATOR;
  if( c == *comment ) class |= COMMENT_CHAR;
  if( c == *escape ) class |= ESCAPE;
  return(class);
}

enum text_mode { DEFAULT, FUNCTION, S_QUOTED, D_QUOTED, COMMENT, ASSIGN, BOOLEAN, NONVALUE, CONDITIONAL };

struct word_classes {
  int *line;
  int *start_pos;
  int *end_pos;
  enum text_mode *mode;
  size_t size;
  size_t capacity;
};

struct word_classes init_words(size_t cap){
  struct word_classes wc;
  wc.line = malloc( sizeof(char*) * cap );
  wc.start_pos = malloc( sizeof(int) * cap );
  wc.end_pos = malloc( sizeof(int) * cap );
  wc.mode = malloc( sizeof(enum text_mode) * cap );
  wc.capacity = cap;
  wc.size = 0;
  return(wc);
}

void free_word_classes(struct word_classes words){
  free(words.line);
  free(words.start_pos);
  free(words.end_pos);
  free(words.mode);
  words.size=0;
  words.capacity=0;
}

void grow_words(struct word_classes *words){
  words->capacity *= 2;
  // assign new memory
  int *n_line = malloc( words->capacity * sizeof(int) );
  int *n_start_pos = malloc( words->capacity * sizeof(int) );
  int *n_end_pos =  malloc( words->capacity * sizeof(int) );
  enum text_mode *n_mode = malloc( words->capacity * sizeof(enum text_mode));
  // copy across .. 
  memcpy( n_line, words->line, sizeof(int) * words->size );
  memcpy( n_start_pos, words->start_pos, sizeof(int) * words->size );
  memcpy( n_end_pos, words->end_pos, sizeof(int) * words->size );
  memcpy( n_mode, words->mode, sizeof(enum text_mode) * words->size );
  // Free the words.. 
  free( words->line );
  free( words->start_pos);
  free( words->end_pos);
  free( words->mode );
  // And assign the variables.. 
  words->line = n_line;
  words->start_pos = n_start_pos;
  words->end_pos = n_end_pos;
  words->mode = n_mode;
}

void push_back( struct word_classes *words, int line_i, int s_pos, int e_pos, enum text_mode m ){
  if( words->size >= words->capacity ){
    grow_words(words);
  }
  size_t i = words->size;
  words->line[i] = line_i;
  words->start_pos[i] = s_pos;
  words->end_pos[i] = e_pos;
  words->mode[i] = m;
  words->size++;
}

int last_word_end(struct word_classes *words){
  if(words->size < 1)
    return(0);
  return( words->end_pos[ words->size - 1 ] );
}

SEXP colorise_R(SEXP input_r){
  if(TYPEOF(input_r) != STRSXP)
    error("input must be a character vector");
  int n = length(input_r);
  if(n < 1)
    error("input must have non-zero length");
  
  struct word_classes words = init_words((size_t)(n * 3));
  enum text_mode current_mode = DEFAULT;
  unsigned char previous_char = 0;


  // This code could really do with being refactored. Instead of goto statements
  // we can either make use of a switch statement or functions. 
  // One can also try to see if it possible to combine the conditions more cleverly
  // by specifying the bits set in the text_mode enum and then perform bitwise 
  // operations.
  // and then we try to parse each one, one by one..
  for(int i=0; i < n; ++i){
    SEXP str_r = STRING_ELT(input_r, i);
    const char *str = CHAR(str_r);
    int start_pos = 0;
    if(current_mode == COMMENT && previous_char != '\\')
      current_mode = DEFAULT;
    // We go through the words; if we find we need to change mode, then we need to 
    // find the start of the mode and so on.. 
    int j=0;
    size_t word_length; // used occassionally
    for(j=0; str[j] != 0; ++j){
      enum char_class cc = char_class( str[j] );
      if(previous_char == '\\')  // should never have special meaning, so should be OK
	goto loop_end;
      if((current_mode == S_QUOTED) && !(cc & S_QUOTE))
	goto loop_end;
      if((current_mode == D_QUOTED) && !(cc & D_QUOTE))
	goto loop_end;
      if(cc == S_QUOTE && current_mode == S_QUOTED){
	// end of quote add quoted .. 
	push_back(&words, i, start_pos, j, current_mode);
	current_mode = DEFAULT;
	start_pos = j+1;
	goto loop_end;
      }
      if(cc == D_QUOTE && current_mode == D_QUOTED){
	// end of quote add quoted
	push_back(&words, i, start_pos, j, current_mode);
	current_mode = DEFAULT;
	start_pos = j+1;
	goto loop_end;
      }
      if(cc == S_QUOTE){
	// begin of single quoted, add previous section
	push_back(&words, i, start_pos, j-1, current_mode);
	current_mode = S_QUOTED;
	start_pos = j;
	goto loop_end;
      }
      if(cc == D_QUOTE){
	// begin of double quoted. add previous section
	push_back(&words, i, start_pos, j-1, current_mode);
	current_mode = D_QUOTED;
	start_pos = j;
	goto loop_end;
      }
      /* if( (word_length = compare_words(str + j, */
      /* 				       (const char*[]){"ifelse", "if", "for", "while"}, 4)) ){ */
      /* 	push_back(&words, i, start_pos, j-1, current_mode); */
      /* 	push_back(&words, i, j, j+word_length-1, CONDITIONAL); */
      /* 	j += word_length - 1; */
      /* 	start_pos = j+1; // hmm */
      /* 	current_mode = DEFAULT; */
      /* 	goto loop_end; */
      /* } */
      if(str[j] == '(' && !char_in(previous_char, (const unsigned char*)"()[]|&^{}\\'\"")){
	int k=j-1;
	int last_end = last_word_end(&words);
	while( char_in(str[k], (const unsigned char*)" \t") && k > last_end )
	  k--;
	while( k >= last_end ){
	  if( char_class(str[k]) & SEP )
	    break;
	  k--;
	}
	push_back(&words, i, start_pos, k, current_mode);
	if(j-1 >= k+1)
	  push_back(&words, i, k+1, j-1, FUNCTION);
	current_mode = DEFAULT;
	start_pos = j;
	goto loop_end;
      }
      if(str[j] == '#'){
	if(j > start_pos)
	  push_back(&words, i, start_pos, j-1, current_mode);
	start_pos = j;
	while(str[j+1] != 0)
	  ++j;
	current_mode = COMMENT;
	goto loop_end;
      }
      if(prefix_cmp( str + j, "<-" )){
	push_back(&words, i, start_pos, j-1, current_mode);
	push_back(&words, i, j, j+1, ASSIGN);
	j++;
	start_pos = j+1; // hmm
	current_mode = DEFAULT;
	goto loop_end;
      }
      if( (word_length = compare_words(str + j, (const char*[]){"TRUE", "FALSE"}, 2)) ){
	push_back(&words, i, start_pos, j-1, current_mode);
	push_back(&words, i, j, j+word_length-1, BOOLEAN);
	j += word_length - 1;
	start_pos = j+1; // hmm
	current_mode = DEFAULT;
	goto loop_end;
      }
      if( (word_length = compare_words(str + j, (const char*[]){"NULL", "NA"}, 2)) ){
	push_back(&words, i, start_pos, j-1, current_mode);
	push_back(&words, i, j, j+word_length-1, NONVALUE);
	j += word_length - 1;
	start_pos = j+1; // hmm
	current_mode = DEFAULT;
	goto loop_end;
      }
    loop_end:
      previous_char = str[j];
    }
    // here we also have to push back..
    push_back(&words, i, start_pos, j, current_mode);
    previous_char = '\n';
  }
  // create a suitable list containing three vectors:
  // 1. Line numbers
  // 2. Words
  // 3. Word classes
  // 4. Terms for the classes
  SEXP ret_data = PROTECT(allocVector(VECSXP, 4));
  SET_VECTOR_ELT(ret_data, 0, allocVector(INTSXP, words.size));
  SET_VECTOR_ELT(ret_data, 1, allocVector(STRSXP, words.size));
  SET_VECTOR_ELT(ret_data, 2, allocVector(INTSXP, words.size));
  SET_VECTOR_ELT(ret_data, 3, allocVector(STRSXP, 9));

  SEXP text_modes = VECTOR_ELT(ret_data, 3);
  SET_STRING_ELT(text_modes, 0, mkChar("default"));
  SET_STRING_ELT(text_modes, 1, mkChar("function"));
  SET_STRING_ELT(text_modes, 2, mkChar("s_quoted"));
  SET_STRING_ELT(text_modes, 3, mkChar("d_quoted"));
  SET_STRING_ELT(text_modes, 4, mkChar("comment"));
  SET_STRING_ELT(text_modes, 5, mkChar("assignment"));
  SET_STRING_ELT(text_modes, 6, mkChar("logical"));
  SET_STRING_ELT(text_modes, 7, mkChar("null"));
  SET_STRING_ELT(text_modes, 8, mkChar("conditional"));

  int *line_nos = INTEGER( VECTOR_ELT(ret_data, 0) );
  SEXP ret_words = VECTOR_ELT(ret_data, 1);
  int *word_modes = INTEGER( VECTOR_ELT(ret_data, 2) );

  // how do I allocate new space for characters? I may need to copy the strings to a string buffer
  // and then use mkChar(). But does mkChar() copy the characters or?
  size_t buffer_size = 1024;
  char *buffer = malloc(buffer_size * sizeof(char));
  bzero((void*)buffer, buffer_size * sizeof(char));
  for(size_t i=0; i < words.size; ++i){
    line_nos[i] = words.line[i];
    word_modes[i] = (int)words.mode[i];
    int l = (words.end_pos[i] - words.start_pos[i]) + 1; // inclusive
    if(buffer_size <= l){
      buffer_size *= 2;
      free(buffer);
      buffer = malloc(buffer_size * sizeof(char));
    }
    if(l <= 0){
      continue;
    }
    memcpy(buffer, CHAR(STRING_ELT(input_r, words.line[i])) + words.start_pos[i], l);
    buffer[l] = 0;
    SET_STRING_ELT(ret_words, i, mkChar(buffer));
  }
  free(buffer);
  free_word_classes(words);
  UNPROTECT(1);
  return( ret_data );
}





