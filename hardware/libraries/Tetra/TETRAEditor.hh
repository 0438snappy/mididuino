#ifndef TETRA_EDITOR_H__
#define TETRA_EDITOR_H__

#include <TETRA.h>

#define NUM_TETRA_EDITOR_PAGES 41

/** Store the "longname" and parameter numbers of a Tetra Editor Page **/
typedef struct tetra_editor_page_t {
  const char* longname;
  uint8_t parameterNumbers[4];
};

class TETRAEditorClass {
public:
	TETRAEditorClass();
	
	int index;
	static tetra_editor_page_t pages[NUM_TETRA_EDITOR_PAGES];
	tetra_editor_page_t *currentPage;
	void setPage(int i);
	void setPageUp();
	void setPageDown();
	int mod(int x, int m);

};
extern TETRAEditorClass TETRAEditor;


#endif /* TETRA_EDITOR_H__ */
