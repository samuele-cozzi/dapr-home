import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AcControllerComponent } from './ac-controller.component';

describe('AcControllerComponent', () => {
  let component: AcControllerComponent;
  let fixture: ComponentFixture<AcControllerComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ AcControllerComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(AcControllerComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
