/*
 * Shutdown (and restart) bits
 */
#ifndef _CTWM_SHUTDOWN_H
#define _CTWM_SHUTDOWN_H

void RestoreWinConfig(TwmWindow *tmp);
void DoShutdown(void) __attribute__((noreturn));
void DoRestart(Time t);
void DoStartWM(Time t, const char *);


#endif /* _CTWM_SHUTDOWN_H */
