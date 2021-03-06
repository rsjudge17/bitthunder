#include <bitthunder.h>
#include <stdlib.h>
#include <string.h>

static int bt_cp(BT_HANDLE hShell, int argc, char **argv) {

	BT_HANDLE hStdout = BT_ShellGetStdout(hShell);
	BT_ERROR Error = BT_ERR_NONE;

	if(argc != 3) {
		bt_fprintf(hStdout, "Usage: %s [source] [destination]\n", argv[0]);
		return 0;
	}

	BT_HANDLE hSource = BT_Open(argv[1], BT_GetModeFlags("rb"), &Error);
	if(!hSource) {
		bt_fprintf(hStdout, "Cannot open source file: %s\n", argv[1]);
		return Error;
	}

	BT_HANDLE hDest = BT_Open(argv[2], BT_GetModeFlags("wb+"), &Error);
	if(!hDest) {
		bt_fprintf(hStdout, "Cannot open destination file: %s\n", argv[2]);
		goto err_source_out;
	}

	void *buffer = BT_kMalloc(BT_CONFIG_SHELL_CMD_CP_BUFFER_SIZE);
	if(!buffer) {
		bt_fprintf(hStdout, "Cannot allocate buffer for copying.\n");
		Error = BT_ERR_NO_MEMORY;
		goto err_dest_out;
	}

	BT_s32 read = BT_Read(hSource, 0, BT_CONFIG_SHELL_CMD_CP_BUFFER_SIZE, buffer);
	while(read > 0) {
		BT_Write(hDest, 0, read, buffer);
		read = BT_Read(hSource, 0, BT_CONFIG_SHELL_CMD_CP_BUFFER_SIZE, buffer);
	}

	BT_kFree(buffer);

err_dest_out:
	BT_CloseHandle(hDest);

err_source_out:
	BT_CloseHandle(hSource);

	return Error;
}

BT_SHELL_COMMAND_DEF oCommand = {
	.szpName = "cp",
	.pfnCommand = bt_cp,
};
