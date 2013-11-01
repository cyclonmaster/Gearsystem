/*
 * Gearsystem - Sega Master System / Game Gear Emulator
 * Copyright (C) 2013  Ignacio Sanchez
 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see http://www.gnu.org/licenses/
 *
 */

#import "GLViewController.h"

@interface GLViewController ()

@end

@implementation GLViewController

@synthesize context = _context;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.theEmulator = [[Emulator alloc]init];
        if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone)
        {
            self.view.hidden = YES;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    
    CGFloat scale;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale=[[UIScreen mainScreen] scale];
    } else {
        scale=1; 
    }
    
    BOOL retina, iPad;
    retina = (scale != 1);
    
    int multiplier = 0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        iPad = NO;
        multiplier = 2;
        view.frame = CGRectMake(31, 15, 128 * multiplier, 112 * multiplier);
    }
    else
    {
        iPad = YES;
        multiplier = 4;
        view.frame = CGRectMake(128, 28, 128 * multiplier, 112 * multiplier);
    }
    
    self.theEmulator.multiplier = multiplier * (retina ? 2 : 1);
    self.theEmulator.retina = retina;
    self.theEmulator.iPad = iPad;
}

- (void)loadRomWithName: (NSString*) name
{
    NSString* path = [NSString stringWithFormat:@"%@/%@", @"/var/mobile/Media/ROMs/Gearsystem", name];
    
    [self.theEmulator loadRomWithPath:path];
    
    self.view.hidden = NO;
    self.paused = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void)update
{
    [self.theEmulator update];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
    [self.theEmulator draw];
}

-(void) releaseContext
{
    [self.theEmulator shutdownGL];
    self.context = nil;
    GLKView *view = (GLKView *)self.view;
    view.context = nil;
    [EAGLContext setCurrentContext:nil];
}

-(void) acquireContext
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
}

@end
