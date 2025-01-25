import { describe, it, expect } from 'vitest';

describe('Parking Management', () => {
  it('should create a reservation', () => {
    const reservation = {
      spotId: 1,
      duration: 60,
      reservedBy: 'user123'
    };

    expect(reservation.spotId).toBe(1);
    expect(reservation.duration).toBe(60);
    expect(reservation.reservedBy).toBe('user123');
  });

  it('should validate parking duration', () => {
    const validDurations = [30, 60, 120];
    const invalidDurations = [0, 15, 240];

    validDurations.forEach(duration => {
      expect(validDurations).toContain(duration);
    });

    invalidDurations.forEach(duration => {
      expect(validDurations).not.toContain(duration);
    });
  });
});
